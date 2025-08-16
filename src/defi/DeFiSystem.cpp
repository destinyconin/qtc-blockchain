// QTC DeFi System Implementation (single file)
#include <iostream>
#include <map>
#include <vector>
#include <memory>
#include <cmath>
#include <algorithm>  // std::min
#include <cstdint>    // uint64_t
#include <ctime>      // time(nullptr)
#include <stdexcept>  // std::runtime_error
#include <string>

namespace QTC {
namespace DeFi {

// ---------------------- Simple Token ----------------------
class Token {
public:
    std::string name;
    std::string symbol;
    uint64_t totalSupply;
    std::map<std::string, uint64_t> balances;

    Token(const std::string& n, const std::string& s, uint64_t supply)
        : name(n), symbol(s), totalSupply(supply) {
        balances["TREASURY"] = supply;
        std::cout << "Token created: " << name << " (" << symbol
                  << ") Supply: " << supply << std::endl;
    }

    bool transfer(const std::string& from, const std::string& to, uint64_t amount) {
        if (balances[from] < amount) return false;
        balances[from] -= amount;
        balances[to]   += amount;
        std::cout << "Transfer: " << amount << " " << symbol
                  << " from " << from << " to " << to << std::endl;
        return true;
    }

    uint64_t balanceOf(const std::string& account) const {
        auto it = balances.find(account);
        return it == balances.end() ? 0 : it->second;
    }
};

// ---------------------- AMM DEX ---------------------------
class DEX {
private:
    struct Pool {
        std::string tokenA;
        std::string tokenB;
        uint64_t reserveA{0};
        uint64_t reserveB{0};
        uint64_t totalShares{0};
        std::map<std::string, uint64_t> shares;
    };

    std::map<std::string, Pool> pools;
    std::map<std::string, std::shared_ptr<Token>> tokens;

    static std::string pairKey(const std::string& a, const std::string& b) {
        return a + "/" + b;
    }

public:
    DEX() { std::cout << "DEX initialized" << std::endl; }

    void addToken(const std::shared_ptr<Token>& token) {
        tokens[token->symbol] = token;
    }

    void createPool(const std::string& tokenA, const std::string& tokenB) {
        if (!tokens.count(tokenA) || !tokens.count(tokenB)) {
            throw std::runtime_error("createPool: token not registered");
        }
        Pool pool;
        pool.tokenA = tokenA;
        pool.tokenB = tokenB;
        pools[pairKey(tokenA, tokenB)] = pool;
        std::cout << "Pool created: " << pairKey(tokenA, tokenB) << std::endl;
    }

    uint64_t addLiquidity(const std::string& user, const std::string& pairId,
                          uint64_t amountA, uint64_t amountB) {
        auto it = pools.find(pairId);
        if (it == pools.end()) throw std::runtime_error("addLiquidity: pool not found");
        Pool& pool = it->second;

        if (!tokens.count(pool.tokenA) || !tokens.count(pool.tokenB))
            throw std::runtime_error("addLiquidity: token not registered");

        // Transfer tokens to pool
        if (!tokens[pool.tokenA]->transfer(user, "DEX_POOL", amountA) ||
            !tokens[pool.tokenB]->transfer(user, "DEX_POOL", amountB)) {
            throw std::runtime_error("addLiquidity: transfer failed");
        }

        // Calculate LP shares
        uint64_t shares = 0;
        if (pool.totalShares == 0) {
            // sqrt(amountA * amountB)
            long double prod = static_cast<long double>(amountA) * static_cast<long double>(amountB);
            shares = static_cast<uint64_t>(std::sqrt(prod));
        } else {
            uint64_t sharesA = (amountA * pool.totalShares) / (pool.reserveA ? pool.reserveA : 1);
            uint64_t sharesB = (amountB * pool.totalShares) / (pool.reserveB ? pool.reserveB : 1);
            shares = std::min(sharesA, sharesB);
        }

        pool.reserveA += amountA;
        pool.reserveB += amountB;
        pool.shares[user] += shares;
        pool.totalShares  += shares;

        std::cout << "Liquidity added: " << amountA << " " << pool.tokenA
                  << " + " << amountB << " " << pool.tokenB
                  << " = " << shares << " LP tokens" << std::endl;

        return shares;
    }

    uint64_t swap(const std::string& user, const std::string& pairId,
                  uint64_t amountIn, bool isTokenA) {
        auto it = pools.find(pairId);
        if (it == pools.end()) throw std::runtime_error("swap: pool not found");
        Pool& pool = it->second;

        const std::string& inSym  = isTokenA ? pool.tokenA : pool.tokenB;
        const std::string& outSym = isTokenA ? pool.tokenB : pool.tokenA;

        if (!tokens.count(inSym) || !tokens.count(outSym))
            throw std::runtime_error("swap: token not registered");

        uint64_t reserveIn  = isTokenA ? pool.reserveA : pool.reserveB;
        uint64_t reserveOut = isTokenA ? pool.reserveB : pool.reserveA;

        if (reserveIn == 0 || reserveOut == 0) throw std::runtime_error("swap: empty pool");

        // x*y=k with 0.3% fee
        uint64_t amountInWithFee = amountIn * 997;
        uint64_t numerator       = amountInWithFee * reserveOut;
        uint64_t denominator     = reserveIn * 1000 + amountInWithFee;
        uint64_t amountOut       = denominator == 0 ? 0 : (numerator / denominator);

        if (amountOut == 0 || amountOut > reserveOut)
            throw std::runtime_error("swap: insufficient output");

        // Execute transfers & update reserves
        if (!tokens[inSym]->transfer(user, "DEX_POOL", amountIn))
            throw std::runtime_error("swap: input transfer failed");

        if (!tokens[outSym]->transfer("DEX_POOL", user, amountOut))
            throw std::runtime_error("swap: output transfer failed");

        if (isTokenA) {
            pool.reserveA += amountIn;
            pool.reserveB -= amountOut;
        } else {
            pool.reserveB += amountIn;
            pool.reserveA -= amountOut;
        }

        std::cout << "Swap: " << amountIn << " " << inSym
                  << " -> " << amountOut << " " << outSym << std::endl;
        return amountOut;
    }

    double getPrice(const std::string& pairId, bool isTokenA) {
        auto it = pools.find(pairId);
        if (it == pools.end()) return 0.0;
        Pool& pool = it->second;
        if (pool.reserveA == 0 || pool.reserveB == 0) return 0.0;
        return isTokenA
            ? static_cast<double>(pool.reserveB) / static_cast<double>(pool.reserveA)
            : static_cast<double>(pool.reserveA) / static_cast<double>(pool.reserveB);
    }
};

// ---------------------- Lending ---------------------------
class LendingPool {
private:
    struct Market {
        std::string token;
        uint64_t totalSupply{0};
        uint64_t totalBorrowed{0};
        double   supplyAPY{3.0};
        double   borrowAPR{5.0};
        std::map<std::string, uint64_t> deposits;
        std::map<std::string, uint64_t> borrows;
    };

    std::map<std::string, Market> markets;
    std::map<std::string, std::shared_ptr<Token>> tokens;

public:
    LendingPool() { std::cout << "Lending Pool initialized" << std::endl; }

    void addMarket(const std::shared_ptr<Token>& token) {
        Market m;
        m.token = token->symbol;
        markets[token->symbol] = m;
        tokens[token->symbol]  = token;
        std::cout << "Lending market added: " << token->symbol << std::endl;
    }

    bool deposit(const std::string& user, const std::string& tokenSymbol, uint64_t amount) {
        if (!tokens.count(tokenSymbol) || !markets.count(tokenSymbol))
            throw std::runtime_error("deposit: market not found");

        Market& market = markets[tokenSymbol];

        if (tokens[tokenSymbol]->transfer(user, "LENDING_POOL", amount)) {
            market.deposits[user] += amount;
            market.totalSupply    += amount;
            updateRates(market);
            std::cout << user << " deposited " << amount << " " << tokenSymbol
                      << " (APY: " << market.supplyAPY << "%)" << std::endl;
            return true;
        }
        return false;
    }

    bool borrow(const std::string& user, const std::string& tokenSymbol, uint64_t amount) {
        if (!tokens.count(tokenSymbol) || !markets.count(tokenSymbol))
            throw std::runtime_error("borrow: market not found");

        Market& market = markets[tokenSymbol];

        if (market.deposits[user] == 0) {
            std::cout << "No collateral" << std::endl;
            return false;
        }
        if (market.totalSupply < market.totalBorrowed + amount) {
            std::cout << "Insufficient liquidity" << std::endl;
            return false;
        }

        if (!tokens[tokenSymbol]->transfer("LENDING_POOL", user, amount))
            throw std::runtime_error("borrow: transfer failed");

        market.borrows[user]   += amount;
        market.totalBorrowed   += amount;
        updateRates(market);

        std::cout << user << " borrowed " << amount << " " << tokenSymbol
                  << " (APR: " << market.borrowAPR << "%)" << std::endl;
        return true;
    }

private:
    static void updateRates(Market& market) {
        if (market.totalSupply == 0) return;
        double utilization = static_cast<double>(market.totalBorrowed) /
                             static_cast<double>(market.totalSupply);
        market.borrowAPR = 3.0 + utilization * 20.0;
        market.supplyAPY = market.borrowAPR * utilization * 0.9;
    }
};

// ---------------------- Staking ---------------------------
class StakingPool {
private:
    struct Stake {
        uint64_t amount{0};
        uint64_t timestamp{0};
        uint64_t lockPeriod{0};
        double   apy{0.0};
    };

    std::map<std::string, std::vector<Stake>> userStakes;
    std::shared_ptr<Token> stakingToken;
    uint64_t totalStaked{0};

public:
    explicit StakingPool(std::shared_ptr<Token> token)
        : stakingToken(std::move(token)) {
        std::cout << "Staking pool created for " << stakingToken->symbol << std::endl;
    }

    bool stake(const std::string& user, uint64_t amount, uint64_t lockDays) {
        if (!stakingToken->transfer(user, "STAKING_POOL", amount)) return false;

        Stake st;
        st.amount     = amount;
        st.timestamp  = static_cast<uint64_t>(time(nullptr));
        st.lockPeriod = lockDays * 86400ULL;
        st.apy        = calculateAPY(lockDays);

        userStakes[user].push_back(st);
        totalStaked += amount;

        std::cout << user << " staked " << amount << " " << stakingToken->symbol
                  << " for " << lockDays << " days at " << st.apy << "% APY" << std::endl;
        return true;
    }

    uint64_t getTotalStaked() const { return totalStaked; }

private:
    static double calculateAPY(uint64_t lockDays) {
        if (lockDays >= 365) return 20.0;
        if (lockDays >= 180) return 15.0;
        if (lockDays >= 90)  return 10.0;
        if (lockDays >= 30)  return 5.0;
        return 2.0;
    }
};

} // namespace DeFi
} // namespace QTC

// ---------------------- Demo Main -------------------------
int main() {
    using namespace QTC::DeFi;

    std::cout << "\n=====================================\n";
    std::cout << "     QTC DeFi System Demo\n";
    std::cout << "=====================================\n";

    // Create tokens
    auto qtc  = std::make_shared<Token>("QTC Token", "QTC",  1000000000ULL);
    auto usdt = std::make_shared<Token>("Tether",    "USDT", 1000000000ULL);

    // Setup initial balances
    qtc->transfer("TREASURY", "Alice", 10000);
    qtc->transfer("TREASURY", "Bob",   10000);
    usdt->transfer("TREASURY", "Alice", 5000);
    usdt->transfer("TREASURY", "Bob",   5000);

    std::cout << "\n=== DEX Demo ===" << std::endl;
    DEX dex;
    dex.addToken(qtc);
    dex.addToken(usdt);
    dex.createPool("QTC", "USDT");

    // Add liquidity
    dex.addLiquidity("Alice", "QTC/USDT", 1000, 500);

    // Perform swap (Bob swaps QTC -> USDT)
    dex.swap("Bob", "QTC/USDT", 100, true);

    std::cout << "QTC/USDT Price: " << dex.getPrice("QTC/USDT", true) << std::endl;

    std::cout << "\n=== Lending Demo ===" << std::endl;
    LendingPool lending;
    lending.addMarket(qtc);
    lending.addMarket(usdt);

    lending.deposit("Alice", "QTC", 1000);
    lending.borrow("Alice", "USDT", 100);

    std::cout << "\n=== Staking Demo ===" << std::endl;
    StakingPool staking(qtc);
    staking.stake("Bob", 500, 30);

    std::cout << "\n=== Final Balances ===" << std::endl;
    std::cout << "Alice QTC: " << qtc->balanceOf("Alice") << std::endl;
    std::cout << "Alice USDT: " << usdt->balanceOf("Alice") << std::endl;
    std::cout << "Bob   QTC: "  << qtc->balanceOf("Bob")   << std::endl;
    std::cout << "Bob   USDT: " << usdt->balanceOf("Bob")  << std::endl;

    return 0;
}
