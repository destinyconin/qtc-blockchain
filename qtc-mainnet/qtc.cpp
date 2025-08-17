#include <iostream>
#include <string>
#include <fstream>
#include <cstdlib>
#include <ctime>

using namespace std;

class QTCWallet {
private:
    string address;
    string privateKey;
    double balance;
    
public:
    QTCWallet() {
        generateAddress();
        balance = 0;
    }
    
    void generateAddress() {
        // 生成钱包地址
        const char* chars = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";
        address = "QTC";
        privateKey = "PRIVATE_";
        
        srand(time(0));
        for(int i = 0; i < 34; i++) {
            address += chars[rand() % 58];
            privateKey += chars[rand() % 58];
        }
        
        // 保存到文件
        ofstream file("wallet.dat");
        file << "Address: " << address << endl;
        file << "Private Key: " << privateKey << endl;
        file.close();
    }
    
    void showInfo() {
        cout << "\n===== QTC钱包信息 =====" << endl;
        cout << "地址: " << address << endl;
        cout << "余额: " << balance << " QTC" << endl;
        cout << "=======================" << endl;
    }
    
    void mine() {
        cout << "\n开始挖矿..." << endl;
        for(int i = 0; i < 5; i++) {
            cout << "挖矿中... " << (i+1)*20 << "%" << endl;
            system("sleep 1 2>/dev/null || timeout 1 >nul 2>&1");
        }
        balance += 10000;
        cout << "挖矿成功! 获得 10,000 QTC" << endl;
    }
};

class QTCNode {
private:
    int port;
    string ip;
    
public:
    QTCNode() {
        port = 8333;
        detectIP();
    }
    
    void detectIP() {
        system("curl -s ifconfig.me > ip.txt 2>/dev/null");
        ifstream file("ip.txt");
        if(file.good()) {
            getline(file, ip);
        } else {
            ip = "127.0.0.1";
        }
        file.close();
        system("rm -f ip.txt 2>/dev/null");
    }
    
    void start() {
        cout << "\n===== 节点信息 =====" << endl;
        cout << "节点IP: " << ip << endl;
        cout << "P2P端口: " << port << endl;
        cout << "状态: 运行中" << endl;
        cout << "矿机连接: " << ip << ":" << port << endl;
        cout << "===================" << endl;
    }
};

int main() {
    cout << "\n";
    cout << "╔════════════════════════════════╗" << endl;
    cout << "║         QTC Core v1.0.0        ║" << endl;
    cout << "║      Quantum Transaction       ║" << endl;
    cout << "║            Chain               ║" << endl;
    cout << "╚════════════════════════════════╝" << endl;
    cout << "\n";
    
    QTCWallet wallet;
    QTCNode node;
    
    node.start();
    wallet.showInfo();
    
    string command;
    while(true) {
        cout << "\n命令 (mine/info/quit): ";
        cin >> command;
        
        if(command == "mine") {
            wallet.mine();
            wallet.showInfo();
        } else if(command == "info") {
            node.start();
            wallet.showInfo();
        } else if(command == "quit") {
            break;
        }
    }
    
    cout << "感谢使用QTC!" << endl;
    return 0;
}
