//
//  AESManager.swift
//  MUKI_test_NDC
//
//  Created by YUAN JUNG LI on 2022/5/18.
//  Copyright © 2022 EICAPITAN. All rights reserved.
//
//
import Foundation
import CommonCrypto

struct AES {

    // MARK: - Value
    // MARK: Private
    private let key: Data
    private let iv: Data


    // MARK: - Initialzier
    init?(key: String, iv: String) {
        guard key.count == kCCKeySizeAES128 || key.count == kCCKeySizeAES256, let keyData = key.data(using: .utf8) else {
            debugPrint("Error: Failed to set a key.")
            return nil
        }
    
        guard iv.count == kCCKeySizeAES128, let ivData = iv.data(using: .utf8) else {
            debugPrint("Error: Failed to set an initial vector.")
            return nil
        }
    
    
        self.key = keyData
        self.iv  = ivData
    }


    // MARK: - Function
    // MARK: Public
    func encrypt(string: String) -> Data? {
        return crypt(data: string.data(using: .utf8), option: CCOperation(kCCEncrypt))
    }

    func decrypt(data: Data?) -> String? {
        guard let decryptedData = crypt(data: data, option: CCOperation(kCCDecrypt)) else { return nil }
        return String(bytes: decryptedData, encoding: .utf8)
    }

    func crypt(data: Data?, option: CCOperation) -> Data? {
        guard let data = data else { return nil }
    
        let cryptLength = data.count + key.count
        var cryptData   = Data(count: cryptLength)
    
        var bytesLength = Int(0)
    
        let status = cryptData.withUnsafeMutableBytes { cryptBytes in
            data.withUnsafeBytes { dataBytes in
                iv.withUnsafeBytes { ivBytes in
                    key.withUnsafeBytes { keyBytes in
                    CCCrypt(option, CCAlgorithm(kCCAlgorithmAES), CCOptions(kCCOptionPKCS7Padding), keyBytes.baseAddress, key.count, ivBytes.baseAddress, dataBytes.baseAddress, data.count, cryptBytes.baseAddress, cryptLength, &bytesLength)
                    }
                }
            }
        }
    
        guard Int32(status) == Int32(kCCSuccess) else {
            debugPrint("Error: Failed to crypt data. Status \(status)")
            return nil
        }
    
        cryptData.removeSubrange(bytesLength..<cryptData.count)
        return cryptData
    }
}

//
//import Foundation
//import CommonCrypto
//
//protocol Cryptable {
//    func encrypt(_ string: String) throws -> Data
//    func decrypt(_ data: Data) throws -> String
//}
//
//struct AES {
//    private let key: Data
//    private let ivSize: Int         = kCCBlockSizeAES128
//    private let options: CCOptions  = CCOptions(kCCOptionPKCS7Padding)
//
//    init(keyString: String) throws {
//        guard keyString.count == kCCKeySizeAES128 else {
//            throw Error.invalidKeySize
//        }
//        self.key = Data(keyString.utf8)
//    }
//}
//
//extension AES {
//    enum Error: Swift.Error {
//        case invalidKeySize
//        case generateRandomIVFailed
//        case encryptionFailed
//        case decryptionFailed
//        case dataToStringFailed
//    }
//}
//
//private extension AES {
//
//    func generateRandomIV(for data: inout Data) throws {
//
//        try data.withUnsafeMutableBytes { dataBytes in
//
//            guard let dataBytesBaseAddress = dataBytes.baseAddress else {
//                throw Error.generateRandomIVFailed
//            }
//
//            let status: Int32 = SecRandomCopyBytes(
//                kSecRandomDefault,
//                kCCBlockSizeAES128,
//                dataBytesBaseAddress
//            )
//
//            guard status == 0 else {
//                throw Error.generateRandomIVFailed
//            }
//        }
//    }
//}
//
//extension AES: Cryptable {
//
//    func encrypt(_ string: String) throws -> Data {
//        let dataToEncrypt = Data(string.utf8)
//
//        let bufferSize: Int = ivSize + dataToEncrypt.count + kCCBlockSizeAES128
//        var buffer = Data(count: bufferSize)
//        try generateRandomIV(for: &buffer)
//
//        var numberBytesEncrypted: Int = 0
//
//        do {
//            try key.withUnsafeBytes { keyBytes in
//                try dataToEncrypt.withUnsafeBytes { dataToEncryptBytes in
//                    try buffer.withUnsafeMutableBytes { bufferBytes in
//
//                        guard let keyBytesBaseAddress = keyBytes.baseAddress,
//                            let dataToEncryptBytesBaseAddress = dataToEncryptBytes.baseAddress,
//                            let bufferBytesBaseAddress = bufferBytes.baseAddress else {
//                                throw Error.encryptionFailed
//                        }
//
//                        let cryptStatus: CCCryptorStatus = CCCrypt( // Stateless, one-shot encrypt operation
//                            CCOperation(kCCEncrypt),                // op: CCOperation
//                            CCAlgorithm(kCCAlgorithmAES),           // alg: CCAlgorithm
//                            options,                                // options: CCOptions
//                            keyBytesBaseAddress,                    // key: the "password"
//                            key.count,                              // keyLength: the "password" size
//                            bufferBytesBaseAddress,                 // iv: Initialization Vector
//                            dataToEncryptBytesBaseAddress,          // dataIn: Data to encrypt bytes
//                            dataToEncryptBytes.count,               // dataInLength: Data to encrypt size
//                            bufferBytesBaseAddress + ivSize,        // dataOut: encrypted Data buffer
//                            bufferSize,                             // dataOutAvailable: encrypted Data buffer size
//                            &numberBytesEncrypted                   // dataOutMoved: the number of bytes written
//                        )
//
//                        guard cryptStatus == CCCryptorStatus(kCCSuccess) else {
//                            throw Error.encryptionFailed
//                        }
//                    }
//                }
//            }
//
//        } catch {
//            throw Error.encryptionFailed
//        }
//
//        let encryptedData: Data = buffer[..<(numberBytesEncrypted + ivSize)]
//        return encryptedData
//    }
//
//    func decrypt(_ data: Data) throws -> String {
//
//        let bufferSize: Int = data.count - ivSize
//        var buffer = Data(count: bufferSize)
//
//        var numberBytesDecrypted: Int = 0
//
//        do {
//            try key.withUnsafeBytes { keyBytes in
//                try data.withUnsafeBytes { dataToDecryptBytes in
//                    try buffer.withUnsafeMutableBytes { bufferBytes in
//
//                        guard let keyBytesBaseAddress = keyBytes.baseAddress,
//                            let dataToDecryptBytesBaseAddress = dataToDecryptBytes.baseAddress,
//                            let bufferBytesBaseAddress = bufferBytes.baseAddress else {
//                                throw Error.encryptionFailed
//                        }
//
//                        let cryptStatus: CCCryptorStatus = CCCrypt( // Stateless, one-shot encrypt operation
//                            CCOperation(kCCDecrypt),                // op: CCOperation
//                            CCAlgorithm(kCCAlgorithmAES128),        // alg: CCAlgorithm
//                            options,                                // options: CCOptions
//                            keyBytesBaseAddress,                    // key: the "password"
//                            key.count,                              // keyLength: the "password" size
//                            dataToDecryptBytesBaseAddress,          // iv: Initialization Vector
//                            dataToDecryptBytesBaseAddress + ivSize, // dataIn: Data to decrypt bytes
//                            bufferSize,                             // dataInLength: Data to decrypt size
//                            bufferBytesBaseAddress,                 // dataOut: decrypted Data buffer
//                            bufferSize,                             // dataOutAvailable: decrypted Data buffer size
//                            &numberBytesDecrypted                   // dataOutMoved: the number of bytes written
//                        )
//
//                        guard cryptStatus == CCCryptorStatus(kCCSuccess) else {
//                            throw Error.decryptionFailed
//                        }
//                    }
//                }
//            }
//        } catch {
//            throw Error.encryptionFailed
//        }
//
//        let decryptedData: Data = buffer[..<numberBytesDecrypted]
//
//        guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
//            throw Error.dataToStringFailed
//        }
//
//        return decryptedString
//    }
//}
//
//do {
//    let aes = try AES(keyString: "FiugQTgPNwCWUY,VhfmM4cKXTLVFvHFe")
//
//    let stringToEncrypt: String = "please encrypt meeee"
//    print("String to encrypt:\t\t\t\(stringToEncrypt)")
//
//    let encryptedData: Data = try aes.encrypt(stringToEncrypt)
//    print("String encrypted (base64):\t\(encryptedData.base64EncodedString())")
//
//    let decryptedData: String = try aes.decrypt(encryptedData)
//    print("String decrypted:\t\t\t\(decryptedData)")
//
//} catch {
//    print("Something went wrong: \(error)")
//}
