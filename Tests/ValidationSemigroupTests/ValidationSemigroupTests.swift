import Prelude
import XCTest
import ValidationSemigroup

func validate(name: String) -> Validation<[String], String> {
    return !name.isEmpty
        ? pure(name)
        : .invalid(["name"])
}

func validate(email: String) -> Validation<[String], String> {
    return email.contains("@")
        ? pure(email)
        : .invalid(["email"])
}

struct User: Equatable, Sendable {
    let first: String
    let last: String
    let email: String
}

class ValidationSemigroupTests: XCTestCase {
    func testValidData() async {
        let user = await { @Sendable first in
            { @Sendable last in
                { @Sendable contact in
                    User.init(first: first, last: last, email: contact)
                }
            }
        }
        <¢>
        validate(name: "Stephen")
        <*> 
        validate(name: "Celis")
        <*> 
        validate(email: "stephen@pointfree.co")

        XCTAssertEqual(
            .valid(
                User(
                    first: "Stephen",
                    last: "Celis",
                    email: "stephen@pointfree.co"
                )
            ),
            user
        )
  }

    func testInvalidData() async {
        let user = await { @Sendable first in
            { @Sendable last in
                { @Sendable contact in
                    User(first: first, last: last, email: contact)
                }
            }
        }
        <¢>
        validate(name: "")
        <*> 
        validate(name: "")
        <*> 
        validate(email: "stephen")

        XCTAssertEqual(
            .invalid(
                ["name", "name", "email"]
            ),
            user
        )
    }
}
