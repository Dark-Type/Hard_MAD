//
//  MockBiometryService.swift
//  Hard_MAD
//
//  Created by dark type on 24.05.2025.
//

@testable import Hard_MAD
import XCTest

// MARK: - Mock Biometry Service

final class MockBiometryService: BiometryServiceProtocol {
    var authenticateResult: Result<Void, Error> = .success(())
    var authenticateCalled = false
    
    private let kBiometryEnabled = "isBiometryEnabled"
    private var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: kBiometryEnabled) }
        set { UserDefaults.standard.set(newValue, forKey: kBiometryEnabled) }
    }
    
    func isBiometryEnabled() -> Bool {
        return isEnabled
    }
    
    func setBiometryEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }
    
    func authenticate(reason: String) async throws {
        authenticateCalled = true
        switch authenticateResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
    
    func setAuthenticateResult(_ result: Result<Void, Error>) {
        authenticateResult = result
    }
}

// MARK: - Auth Service Tests

final class AuthServiceTests: XCTestCase {
    var sut: AuthService!
    var mockBiometryService: MockBiometryService!
    
    override func setUp() {
        super.setUp()
        mockBiometryService = MockBiometryService()
        
    
        sut = AuthService(
            profileService: ProfileService(keychain: KeychainService()),
            biometryService: mockBiometryService
        )
        
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "isBiometryEnabled")
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "isBiometryEnabled")
        super.tearDown()
    }
    
    // MARK: - Core Biometry Logic Tests
    
    func testBiometrySetupAndPermissions() {
       
       
        XCTAssertFalse(sut.isTouchIDEnabled())
        XCTAssertEqual(sut.authenticationState(), .notLoggedIn)
        
      
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        XCTAssertEqual(sut.authenticationState(), .loggedIn)
        
    
        sut.setTouchIDEnabled(true)
        XCTAssertTrue(sut.isTouchIDEnabled())
        XCTAssertEqual(sut.authenticationState(), .needsBiometry)
        
     
        sut.setTouchIDEnabled(false)
        XCTAssertFalse(sut.isTouchIDEnabled())
        XCTAssertEqual(sut.authenticationState(), .loggedIn)
        
      
        try? sut.logout()
        XCTAssertFalse(sut.isTouchIDEnabled())
        XCTAssertEqual(sut.authenticationState(), .notLoggedIn)
    }
    
    func testAuthenticationStateLogic() {
    
        
        let testCases: [(isLoggedIn: Bool, biometryEnabled: Bool, expectedState: AuthState)] = [
            (false, false, .notLoggedIn),
            (false, true, .notLoggedIn),
            (true, false, .loggedIn),
            (true, true, .needsBiometry)
        ]
        
        for testCase in testCases {
            UserDefaults.standard.set(testCase.isLoggedIn, forKey: "isLoggedIn")
            sut.setTouchIDEnabled(testCase.biometryEnabled)
            
            let actualState = sut.authenticationState()
            XCTAssertEqual(actualState, testCase.expectedState,
                           "Failed for logged in: \(testCase.isLoggedIn), biometry: \(testCase.biometryEnabled)")
        }
    }
    
    func testBiometryAuthentication() async throws {
        mockBiometryService.setAuthenticateResult(.success(()))
        
        try await sut.authenticateWithBiometrics(reason: "Test")
        XCTAssertTrue(mockBiometryService.authenticateCalled)
    }
    
    func testBiometryAuthenticationFailure() async {

        mockBiometryService.setAuthenticateResult(.failure(AuthError.biometryFailed))
        
        do {
            try await sut.authenticateWithBiometrics(reason: "Test")
            XCTFail("Should have thrown error")
        } catch {
            XCTAssertTrue(error is AuthError)
        }
    }
}
