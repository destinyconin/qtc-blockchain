// QTC Blockchain - Simple Version for Beginners
#include <iostream>
#include <vector>
#include <string>
#include <ctime>
#include <sstream>
#include <iomanip>
#include <openssl/sha.h>

using namespace std;

// Transaction class
class Transaction {
public:
    string from;
    string to;
    double amount;
    time_t timestamp;
    
    Transaction(string f, string t, double a) {
        from = f;
        to = t;
        amount = a;
        timestamp = time(nullptr);
    }
    
    string toString() const {
        stringstream ss;
        ss << from << "->" << to << ":" << amount << "@" << timestamp;
        return ss.str();
    }
};

// Block class
class Block {
public:
    int index;
    time_t timestamp;
    vector<Transaction> transactions;
    string previousHash;
    string hash;
    int nonce;
    
    Block(int idx, string prevHash) {
        index = idx;
        previousHash = prevHash;
        timestamp = time(nullptr);
        nonce = 0;
        hash = calculateHash();
    }
    
    void addTransaction(const Transaction& t) {
        transactions.push_back(t);
    }
    
    string calculateHash() {
        stringstream ss;
        ss << index << timestamp << previousHash << nonce;
        for(const auto& t : transactions) {
            ss << t.toString();
        }
        
        string data = ss.str();
        unsigned char hash[SHA256_DIGEST_LENGTH];
        SHA256((unsigned char*)data.c_str(), data.length(), hash);
        
        stringstream result;
        for(int i = 0; i < SHA256_DIGEST_LENGTH; i++) {
            result << hex << setw(2) << setfill('0') << (int)hash[i];
        }
        return result.str();
    }
    
    void mineBlock(int difficulty) {
        string target(difficulty, '0');
        cout << "Mining block " << index << "..." << endl;
        
        while(hash.substr(0, difficulty) != target) {
            nonce++;
            hash = calculateHash();
            
            // Show progress every 100000 attempts
            if(nonce % 100000 == 0) {
                cout << "   Attempts: " << nonce << endl;
            }
        }
        
        cout << "Block mined successfully! Hash: " << hash << endl;
        cout << "   Total attempts: " << nonce << endl << endl;
    }
};

// Blockchain class
class Blockchain {
public:
    vector<Block> chain;
    int difficulty;
    vector<Transaction> pendingTransactions;
    double miningReward;
    
    Blockchain() {
        difficulty = 2;  // Difficulty level (2 leading zeros required)
        miningReward = 10000;  // 10000 QTC per block
        
        // Create genesis block
        Block genesis(0, "0");
        genesis.addTransaction(Transaction("Genesis", "Genesis", 0));
        chain.push_back(genesis);
        cout << "Genesis block created!" << endl << endl;
    }
    
    Block getLastBlock() {
        return chain.back();
    }
    
    void createTransaction(const Transaction& t) {
        pendingTransactions.push_back(t);
        cout << "Transaction added to pending queue" << endl;
    }
    
    void minePendingTransactions(string minerAddress) {
        Block newBlock(chain.size(), getLastBlock().hash);
        
        // Add mining reward transaction
        newBlock.addTransaction(Transaction("System", minerAddress, miningReward));
        
        // Add all pending transactions
        for(const auto& t : pendingTransactions) {
            newBlock.addTransaction(t);
        }
        
        // Mine the block
        newBlock.mineBlock(difficulty);
        
        // Add to chain
        chain.push_back(newBlock);
        
        // Clear pending transactions
        pendingTransactions.clear();
        
        cout << "New block added to blockchain!" << endl;
        cout << "   Block height: " << chain.size() - 1 << endl;
        cout << "   Transactions: " << newBlock.transactions.size() << endl << endl;
    }
    
    double getBalance(string address) {
        double balance = 0;
        
        for(const auto& block : chain) {
            for(const auto& trans : block.transactions) {
                if(trans.from == address) {
                    balance -= trans.amount;
                }
                if(trans.to == address) {
                    balance += trans.amount;
                }
            }
        }
        
        return balance;
    }
    
    void printChain() {
        cout << "\n=== QTC Blockchain Info ===" << endl;
        cout << "Total blocks: " << chain.size() << endl;
        cout << "Mining difficulty: " << difficulty << endl;
        cout << "Block reward: " << miningReward << " QTC" << endl;
        cout << "Pending transactions: " << pendingTransactions.size() << endl;
        cout << "========================\n" << endl;
    }
};

int main() {
    cout << "\n";
    cout << "=====================================" << endl;
    cout << "      Welcome to QTC Blockchain     " << endl;
    cout << "    Total Supply: 1 Trillion QTC    " << endl;
    cout << "    Block Reward: 10,000 QTC        " << endl;
    cout << "=====================================" << endl;
    cout << "\n";
    
    // Create blockchain
    Blockchain qtc;
    
    // Create wallet addresses
    string alice = "Alice";
    string bob = "Bob";
    string miner = "Miner";
    
    cout << "Creating user wallets:" << endl;
    cout << "   - Alice" << endl;
    cout << "   - Bob" << endl;
    cout << "   - Miner" << endl << endl;
    
    // Miner mines first block for reward
    cout << "=== Starting Mining ===" << endl;
    qtc.minePendingTransactions(miner);
    
    // Create some transactions
    cout << "=== Creating Transactions ===" << endl;
    qtc.createTransaction(Transaction(miner, alice, 1000));
    qtc.createTransaction(Transaction(miner, bob, 500));
    cout << endl;
    
    // Mine to confirm transactions
    cout << "=== Mining to Confirm Transactions ===" << endl;
    qtc.minePendingTransactions(miner);
    
    // Alice sends to Bob
    cout << "=== Alice Sends to Bob ===" << endl;
    qtc.createTransaction(Transaction(alice, bob, 200));
    cout << endl;
    
    // Mine again
    cout << "=== Mining to Confirm ===" << endl;
    qtc.minePendingTransactions(miner);
    
    // Show balances
    cout << "=== Account Balances ===" << endl;
    cout << "   Miner: " << qtc.getBalance(miner) << " QTC" << endl;
    cout << "   Alice: " << qtc.getBalance(alice) << " QTC" << endl;
    cout << "   Bob: " << qtc.getBalance(bob) << " QTC" << endl;
    cout << endl;
    
    // Show blockchain info
    qtc.printChain();
    
    cout << "QTC Blockchain running successfully!" << endl;
    cout << "Note: This is a simplified version for learning blockchain basics." << endl;
    cout << endl;
    
    return 0;
}
