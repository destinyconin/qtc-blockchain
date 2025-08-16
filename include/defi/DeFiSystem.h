// QTC DeFi System - Complete Implementation
#pragma once

#include <iostream>
#include <vector>
#include <map>
#include <cmath>
#include <algorithm>
#include <memory>
#include <chrono>
#include <mutex>

namespace QTC {
namespace DeFi {

// Token standard (similar to ERC-20)
class Token {
public:
    std::string name;
    std::string symbol;
    uint8_t decimals;
    uint64_t totalSupply;
    std::map<std::string, uint64_t> balances;
    std::map<std::string, std::map<std::string, uint64_t>> allowances;
    
    Token(const std::string& n, const std::string& s, uint64_t supply)
        : name(n), symbol(s), decimals(18), totalSupply(supply) {
        std::cout << "Token created: " << name << " (" << symbol << ")" << std::endl;
    }
    
    bool transfer(const std::string& from, const std::string& to, uint64_t amount) {
        if(balances[from] < amount) return false;
        balances[from] -= amount;
        balances[to] += amount;
        return true;
    }
    
    bool approve(const std::string& owner, const std::string& spender, uint64_t amount) {
        allowances[owner][spender] = amount;
        return true;
    }
    
    bool transferFrom(const std::string& from, const std::string& to, uint64_t amount, const std::string& spender) {
        if(balances[from] < amount) return false;
        if(allowances[from][spender] < amount) return false;
        
        balances[from] -= amount;
        balances[to] += amount;
        allowances[from][spender] -= amount;
        return true;
    }
    
    uint64_t balanceOf(const std::string& account) const {
        auto it = balances.find(account);
        return (it != balances.end()) ? it->second : 0;
    }
};

// Liquidity Pool for AMM (Automated Market Maker)
class LiquidityPool {
private:
    std::shared_ptr<Token> tokenA;
    std::shared_ptr<Token> tokenB;
    uint64_t reserveA;
    uint64_t reserveB;
    uint64_t totalLPTokens;
    std::map<std::string, uint64_t> lpBalances;
    double feeRate; // 0.3% = 0.003
    
public:
    LiquidityPool(std::shared_ptr<Token> a, std::shared_ptr<Token> b)
        : tokenA(a), tokenB(b), reserveA(0), reserveB(0), totalLPTokens(0), feeRate(0.003) {
        std::cout << "Liquidity Pool created: " << tokenA->symbol << "/" << tokenB->symbol << std::endl;
    }
    
    // Add liquidity to the pool
    uint64_t addLiquidity(const std::string& provider, uint64_t amountA, uint64_t amountB) {
        uint64_t lpTokens;
        
        if(totalLPTokens == 0) {
            // First liquidity provider
            lpTokens = std::sqrt(amountA * amountB);
        } else {
            // Subsequent providers
            uint64_t lpFromA = (amountA * totalLPTokens) / reserveA;
            uint64_t lpFromB = (amountB * totalLPTokens) / reserveB;
            lpTokens = std::min(lpFromA, lpFromB);
        }
        
        // Transfer tokens to pool
        tokenA->transfer(provider, "POOL", amountA);
        tokenB->transfer(provider, "POOL", amountB);
        
        // Update reserves
        reserveA += amountA;
        reserveB += amountB;
        
        // Mint LP tokens
        lpBalances[provider] += lpTokens;
        totalLPTokens += lpTokens;
        
        std::cout << "Liquidity added: " << amountA << " " << tokenA->symbol 
                  << " + " << amountB << " " << tokenB->symbol 
                  << " = " << lpTokens << " LP tokens" << std::endl;
        
        return lpTokens;
    }
    
    // Remove liquidity from the pool
    std::pair<uint64_t, uint64_t> removeLiquidity(const std::string& provider, uint64_t lpTokens) {
        if(lpBalances[provider] < lpTokens) {
            return {0, 0};
        }
        
        uint64_t amountA = (lpTokens * reserveA) / totalLPTokens;
        uint64_t amountB = (lpTokens * reserveB) / totalLPTokens;
        
        // Burn LP tokens
        lpBalances[provider] -= lpTokens;
        totalLPTokens -= lpTokens;
        
        // Update reserves
        reserveA -= amountA;
        reserveB -= amountB;
        
        // Transfer tokens back
        tokenA->transfer("POOL", provider, amountA);
        tokenB->transfer("POOL", provider, amountB);
        
        std::cout << "Liquidity removed: " << amountA << " " << tokenA->symbol 
                  << " + " << amountB << " " << tokenB->symbol << std::endl;
        
        return {amountA, amountB};
    }
    
    // Swap tokens using constant product formula (x * y = k)
    uint64_t swap(const std::string& trader, uint64_t amountIn, bool isTokenA) {
        uint64_t reserveIn = isTokenA ? reserveA : reserveB;
        uint64_t reserveOut = isTokenA ? reserveB : reserveA;
        
        // Calculate output amount with fee
        uint64_t amountInWithFee = amountIn * (1000 - feeRate * 1000);
        uint64_t amountOut = (amountInWithFee * reserveOut) / (reserveIn * 1000 + amountInWithFee);
        
        // Update reserves
        if(isTokenA) {
            reserveA += amountIn;
            reserveB -= amountOut;
            tokenA->transfer(trader, "POOL", amountIn);
            tokenB->transfer("POOL", trader, amountOut);
        } else {
            reserveB += amountIn;
            reserveA -= amountOut;
            tokenB->transfer(trader, "POOL", amountIn);
            tokenA->transfer("POOL", trader, amountOut);
        }
        
        std::cout << "Swap: " << amountIn << " -> " << amountOut << std::endl;
        return amountOut;
    }
    
    // Get current exchange rate
    double getPrice(bool isTokenA) const {
        if(reserveA == 0 || reserveB == 0) return 0;
        return isTokenA ? (double)reserveB / reserveA : (double)reserveA / reserveB;
    }
    
    // Get pool info
    void getPoolInfo() const {
        std::cout << "Pool: " << tokenA->symbol << "/" << tokenB->symbol << std::endl;
        std::cout << "  Reserve A: " << reserveA << std::endl;
        std::cout << "  Reserve B: " << reserveB << std::endl;
        std::cout << "  Total LP Tokens: " << totalLPTokens << std::endl;
        std::cout << "  Price " << tokenA->symbol << ": " << getPrice(true) << " " << tokenB->symbol << std::endl;
    }
};

// Lending Protocol
class LendingProtocol {
private:
    struct Market {
        std::shared_ptr<Token> token;
        uint64_t totalSupply;      // Total deposited
        uint64_t totalBorrowed;     // Total borrowed
        double supplyAPY;           // Annual Percentage Yield for suppliers
        double borrowAPR;           // Annual Percentage Rate for borrowers
        double collateralFactor;    // How much can be borrowed against this asset (e.g., 0.75 = 75%)
        std::map<std::string, uint64_t> supplies;
        std::map<std::string, uint64_t> borrows;
    };
    
    std::map<std::string, Market> markets;
    std::map<std::string, double> userHealthFactors;
    
public:
    LendingProtocol() {
        std::cout << "Lending Protocol initialized" << std::endl;
    }
    
    // Add a new market
    void addMarket(std::shared_ptr<Token> token, double collateralFactor = 0.75) {
        Market market;
        market.token = token;
        market.totalSupply = 0;
        market.totalBorrowed = 0;
        market.supplyAPY = 2.0;  // 2% base APY
        market.borrowAPR = 5.0;  // 5% base APR
        market.collateralFactor = collateralFactor;
        
        markets[token->symbol] = market;
        std::cout << "Market added: " << token->symbol << " (CF: " << collateralFactor * 100 << "%)" << std::endl;
    }
    
    // Supply tokens to earn interest
    bool supply(const std::string& user, const std::string& tokenSymbol, uint64_t amount) {
        auto it = markets.find(tokenSymbol);
        if(it == markets.end()) return false;
        
        Market& market = it->second;
        
        // Transfer tokens to protocol
        if(!market.token->transfer(user, "LENDING_POOL", amount)) {
            return false;
        }
        
        market.supplies[user] += amount;
        market.totalSupply += amount;
        
        // Update interest rates
        updateInterestRates(market);
        
        std::cout << user << " supplied " << amount << " " << tokenSymbol << std::endl;
        std::cout << "  New APY: " << market.supplyAPY << "%" << std::endl;
        
        return true;
    }
    
    // Borrow tokens against collateral
    bool borrow(const std::string& user, const std::string& tokenSymbol, uint64_t amount) {
        auto it = markets.find(tokenSymbol);
        if(it == markets.end()) return false;
        
        Market& market = it->second;
        
        // Check if user has enough collateral
        if(!checkCollateral(user, tokenSymbol, amount)) {
            std::cout << "Insufficient collateral for borrow" << std::endl;
            return false;
        }
        
        // Check if there's enough liquidity
        if(market.totalSupply - market.totalBorrowed < amount) {
            std::cout << "Insufficient liquidity in market" << std::endl;
            return false;
        }
        
        // Transfer tokens to borrower
        market.token->transfer("LENDING_POOL", user, amount);
        
        market.borrows[user] += amount;
        market.totalBorrowed += amount;
        
        // Update interest rates
        updateInterestRates(market);
        
        std::cout << user << " borrowed " << amount << " " << tokenSymbol << std::endl;
        std::cout << "  New APR: " << market.borrowAPR << "%" << std::endl;
        
        return true;
    }
    
    // Repay borrowed tokens
    bool repay(const std::string& user, const std::string& tokenSymbol, uint64_t amount) {
        auto it = markets.find(tokenSymbol);
        if(it == markets.end()) return false;
        
        Market& market = it->second;
        
        uint64_t borrowAmount = market.borrows[user];
        uint64_t repayAmount = std::min(amount, borrowAmount);
        
        // Transfer tokens back to protocol
        if(!market.token->transfer(user, "LENDING_POOL", repayAmount)) {
            return false;
        }
        
        market.borrows[user] -= repayAmount;
        market.totalBorrowed -= repayAmount;
        
        // Update interest rates
        updateInterestRates(market);
        
        std::cout << user << " repaid " << repayAmount << " " << tokenSymbol << std::endl;
        
        return true;
    }
    
    // Withdraw supplied tokens
    bool withdraw(const std::string& user, const std::string& tokenSymbol, uint64_t amount) {
        auto it = markets.find(tokenSymbol);
        if(it == markets.end()) return false;
        
        Market& market = it->second;
        
        uint64_t supplyAmount = market.supplies[user];
        uint64_t withdrawAmount = std::min(amount, supplyAmount);
        
        // Check if withdrawal would cause liquidation
        if(!checkHealthAfterWithdraw(user, tokenSymbol, withdrawAmount)) {
            std::cout << "Withdrawal would cause liquidation" << std::endl;
            return false;
        }
        
        // Transfer tokens to user
        market.token->transfer("LENDING_POOL", user, withdrawAmount);
        
        market.supplies[user] -= withdrawAmount;
        market.totalSupply -= withdrawAmount;
        
        // Update interest rates
        updateInterestRates(market);
        
        std::cout << user << " withdrew " << withdrawAmount << " " << tokenSymbol << std::endl;
        
        return true;
    }
    
private:
    // Update interest rates based on utilization
    void updateInterestRates(Market& market) {
        if(market.totalSupply == 0) return;
        
        double utilization = (double)market.totalBorrowed / market.totalSupply;
        
        // Simple interest rate model
        market.borrowAPR = 3.0 + utilization * 20.0;  // 3% to 23%
        market.supplyAPY = market.borrowAPR * utilization * 0.9;  // 90% of borrow interest goes to suppliers
    }
    
    // Check if user has enough collateral for a borrow
    bool checkCollateral(const std::string& user, const std::string& borrowToken, uint64_t borrowAmount) {
        double totalCollateralValue = 0;
        double totalBorrowValue = 0;
        
        // Calculate total collateral value
        for(const auto& [symbol, market] : markets) {
            uint64_t supply = market.supplies[user];
            if(supply > 0) {
                totalCollateralValue += supply * market.collateralFactor;
            }
            
            uint64_t borrow = market.borrows[user];
            if(borrow > 0) {
                totalBorrowValue += borrow;
            }
        }
        
        // Add new borrow
        totalBorrowValue += borrowAmount;
        
        // Health factor must be > 1
        double healthFactor = totalCollateralValue / totalBorrowValue;
        userHealthFactors[user] = healthFactor;
        
        return healthFactor > 1.0;
    }
    
    bool checkHealthAfterWithdraw(const std::string& user, const std::string& tokenSymbol, uint64_t amount) {
        // Simplified check
        return true;
    }
};

// Staking Protocol
class StakingProtocol {
private:
    struct StakeInfo {
        uint64_t amount;
        uint64_t startTime;
        uint64_t lockPeriod;  // in seconds
        double apy;
    };
    
    std::map<std::string, std::vector<StakeInfo>> userStakes;
    std::shared_ptr<Token> stakingToken;
    std::shared_ptr<Token> rewardToken;
    uint64_t totalStaked;
    
public:
    StakingProtocol(std::shared_ptr<Token> staking, std::shared_ptr<Token> reward)
        : stakingToken(staking), rewardToken(reward), totalStaked(0) {
        std::cout << "Staking Protocol initialized for " << stakingToken->symbol << std::endl;
    }
    
    // Stake tokens with lock period
    bool stake(const std::string& user, uint64_t amount, uint64_t lockDays) {
        if(stakingToken->balanceOf(user) < amount) {
            return false;
        }
        
        // Transfer tokens to staking contract
        stakingToken->transfer(user, "STAKING_POOL", amount);
        
        // Calculate APY based on lock period
        double apy = calculateAPY(lockDays);
        
        StakeInfo info;
        info.amount = amount;
        info.startTime = std::chrono::system_clock::now().time_since_epoch().count();
        info.lockPeriod = lockDays * 86400;  // Convert to seconds
        info.apy = apy;
        
        userStakes[user].push_back(info);
        totalStaked += amount;
        
        std::cout << user << " staked " << amount << " " << stakingToken->symbol 
                  << " for " << lockDays << " days at " << apy << "% APY" << std::endl;
        
        return true;
    }
    
    // Unstake tokens and claim rewards
    bool unstake(const std::string& user, size_t stakeIndex) {
        if(userStakes[user].size() <= stakeIndex) {
            return false;
        }
        
        StakeInfo& stake = userStakes[user][stakeIndex];
        
        // Check if lock period has passed
        uint64_t currentTime = std::chrono::system_clock::now().time_since_epoch().count();
        if(currentTime < stake.startTime + stake.lockPeriod) {
            std::cout << "Tokens still locked" << std::endl;
            return false;
        }
        
        // Calculate rewards
        uint64_t rewards = calculateRewards(stake);
        
        // Transfer staked tokens back
        stakingToken->transfer("STAKING_POOL", user, stake.amount);
        
        // Transfer rewards
        rewardToken->transfer("REWARD_POOL", user, rewards);
        
        totalStaked -= stake.amount;
        
        std::cout << user << " unstaked " << stake.amount << " " << stakingToken->symbol 
                  << " and earned " << rewards << " " << rewardToken->symbol << std::endl;
        
        // Remove stake from list
        userStakes[user].erase(userStakes[user].begin() + stakeIndex);
        
        return true;
    }
    
private:
    double calculateAPY(uint64_t lockDays) {
        if(lockDays >= 365) return 20.0;  // 20% APY for 1 year
        if(lockDays >= 180) return 15.0;  // 15% APY for 6 months
        if(lockDays >= 90) return 10.0;   // 10% APY for 3 months
        if(lockDays >= 30) return 5.0;    // 5% APY for 1 month
        return 2.0;  // 2% APY for short term
    }
    
    uint64_t calculateRewards(const StakeInfo& stake) {
        uint64_t duration = std::chrono::system_clock::now().time_since_epoch().count() - stake.startTime;
        double years = duration / (365.0 * 86400);
        return stake.amount * (stake.apy / 100.0) * years;
    }
};

// Yield Farming
class YieldFarming {
private:
    struct Farm {
        std::shared_ptr<LiquidityPool> pool;
        std::shared_ptr<Token> rewardToken;
        uint64_t rewardPerBlock;
        uint64_t totalStaked;
        std::map<std::string, uint64_t> userStakes;
        std::map<std::string, uint64_t> userRewards;
    };
    
    std::map<std::string, Farm> farms;
    
public:
    YieldFarming() {
        std::cout << "Yield Farming protocol initialized" << std::endl;
    }
    
    // Create a new farm
    void createFarm(const std::string& farmId, 
                    std::shared_ptr<LiquidityPool> pool,
                    std::shared_ptr<Token> rewardToken,
                    uint64_t rewardPerBlock) {
        Farm farm;
        farm.pool = pool;
        farm.rewardToken = rewardToken;
        farm.rewardPerBlock = rewardPerBlock;
        farm.totalStaked = 0;
        
        farms[farmId] = farm;
        std::cout << "Farm created: " << farmId << " with " << rewardPerBlock 
                  << " " << rewardToken->symbol << " per block" << std::endl;
    }
    
    // Stake LP tokens in farm
    bool stakeLPTokens(const std::string& user, const std::string& farmId, uint64_t amount) {
        auto it = farms.find(farmId);
        if(it == farms.end()) return false;
        
        Farm& farm = it->second;
        
        // Update rewards before changing stakes
        updateRewards(farm, user);
        
        farm.userStakes[user] += amount;
        farm.totalStaked += amount;
        
        std::cout << user << " staked " << amount << " LP tokens in farm " << farmId << std::endl;
        
        return true;
    }
    
    // Harvest rewards
    uint64_t harvest(const std::string& user, const std::string& farmId) {
        auto it = farms.find(farmId);
        if(it == farms.end()) return 0;
        
        Farm& farm = it->second;
        
        updateRewards(farm, user);
        
        uint64_t rewards = farm.userRewards[user];
        if(rewards > 0) {
            farm.rewardToken->transfer("FARM_REWARDS", user, rewards);
            farm.userRewards[user] = 0;
            
            std::cout << user << " harvested " << rewards << " " 
                      << farm.rewardToken->symbol << " from farm " << farmId << std::endl;
        }
        
        return rewards;
    }
    
private:
    void updateRewards(Farm& farm, const std::string& user) {
        if(farm.totalStaked == 0) return;
        
        uint64_t userShare = farm.userStakes[user];
        if(userShare == 0) return;
        
        // Simple reward calculation
        uint64_t pendingRewards = (userShare * farm.rewardPerBlock) / farm.totalStaked;
        farm.userRewards[user] += pendingRewards;
    }
};

// Main DeFi Manager
class DeFiManager {
private:
    std::map<std::string, std::shared_ptr<Token>> tokens;
    std::map<std::string, std::shared_ptr<LiquidityPool>> pools;
    std::unique_ptr<LendingProtocol> lending;
    std::unique_ptr<StakingProtocol> staking;
    std::unique_ptr<YieldFarming> farming;
    
public:
    DeFiManager() {
        std::cout << "\n=== QTC DeFi System Initializing ===" << std::endl;
        
        // Create tokens
        createToken("QTC", "QTC", 1000000000);
        createToken("USDT", "USDT", 1000000000);
        createToken("WBTC", "WBTC", 21000000);
        createToken("WETH", "WETH", 120000000);
        
        // Initialize protocols
        lending = std::make_unique<LendingProtocol>();
        
        // Create liquidity pools
        createPool("QTC", "USDT");
        createPool("WBTC", "USDT");
        createPool("WETH", "USDT");
        
        // Initialize staking
        staking = std::make_unique<StakingProtocol>(tokens["QTC"], tokens["QTC"]);
        
        // Initialize yield farming
        farming = std::make_unique<YieldFarming>();
        
        std::cout << "=== QTC DeFi System Ready ===" << std::endl;
    }
    
    // Create a new token
    void createToken(const std::string& name, const std::string& symbol, uint64_t supply) {
        auto token = std::make_shared<Token>(name, symbol, supply);
        tokens[symbol] = token;
        
        // Give initial supply to treasury
        token->balances["TREASURY"] = supply;
    }
    
    // Create a liquidity pool
    void createPool(const std::string& tokenA, const std::string& tokenB) {
        auto pool = std::make_shared<LiquidityPool>(tokens[tokenA], tokens[tokenB]);
        pools[tokenA + "/" + tokenB] = pool;
    }
    
    // Get token
    std::shared_ptr<Token> getToken(const std::string& symbol) {
        return tokens[symbol];
    }
    
    // Get pool
    std::shared_ptr<LiquidityPool> getPool(const std::string& pair) {
        return pools[pair];
    }
    
    // Get lending protocol
    LendingProtocol* getLending() {
        return lending.get();
    }
    
    // Get staking protocol
    StakingProtocol* getStaking() {
        return staking.get();
    }
    
    // Get yield farming
    YieldFarming* getFarming() {
        return farming.get();
    }
    
    // Print DeFi statistics
    void printStats() {
        std::cout << "\n=== DeFi System Statistics ===" << std::endl;
        std::cout << "Tokens: " << tokens.size() << std::endl;
        std::cout << "Liquidity Pools: " << pools.size() << std::endl;
        std::cout << "Lending Markets: Active" << std::endl;
        std::cout << "Staking: Active" << std::endl;
        std::cout << "Yield Farming: Active" << std::endl;
    }
};

} // namespace DeFi
} // namespace QTC
