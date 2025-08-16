// QTC Blockchain - Advanced Version with All Features
#include <iostream>
#include <thread>
#include <chrono>

// Include all advanced features
#include "network/P2PNode.cpp"
#include "crypto/ZKProof.cpp"
#include "rpc/RPCServer.cpp"
#include "contracts/VirtualMachine.cpp"

using namespace QTC;

int main() {
    std::cout << "\n";
    std::cout << "========================================" << std::endl;
    std::cout << "   QTC Blockchain - Advanced Version   " << std::endl;
    std::cout << "========================================" << std::endl;
    std::cout << "\n";
    
    // Initialize all components
    std::cout << "Initializing advanced features...\n" << std::endl;
    
    // 1. P2P Network
    P2PNode p2p(8333);
    p2p.start();
    
    // 2. Zero-Knowledge Proof System
    ZKProof zkSystem;
    
    // 3. RPC Server
    RPCServer rpc(8332);
    rpc.start();
    
    // 4. Smart Contract VM
    VirtualMachine vm;
    
    std::cout << "\n";
    std::cout << "========================================" << std::endl;
    std::cout << "        All Systems Operational!        " << std::endl;
    std::cout << "========================================" << std::endl;
    std::cout << "\n";
    std::cout << "Services running:" << std::endl;
    std::cout << "  • P2P Network: Port 8333" << std::endl;
    std::cout << "  • RPC Server: http://localhost:8332" << std::endl;
    std::cout << "  • Web Wallet: Open web/index.html" << std::endl;
    std::cout << "  • Smart Contracts: Ready" << std::endl;
    std::cout << "  • ZK-SNARKs: Enabled" << std::endl;
    std::cout << "\n";
    std::cout << "Press Ctrl+C to stop..." << std::endl;
    
    // Keep running
    while(true) {
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }
    
    return 0;
}
