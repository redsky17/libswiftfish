import struct Foundation.URL
import Foundation

import OpenAPIRuntime
import OpenAPIURLSession

public struct libswiftfish {
    public init() {}

    struct ExtendedISO8601DateTranscoder: DateTranscoder {
        func encode(_ date: Date) throws -> String {
            ISO8601DateFormatter().string(from: date)
        }

        func decode(_ string: String) throws -> Date {
            let extendedFormatter = ISO8601DateFormatter()
            extendedFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let dateFormatters = [ISO8601DateFormatter(), extendedFormatter]
            for formatter in dateFormatters {
                if let result = formatter.date(from: string) {
                    return result
                }
            }
            throw DecodingError.dataCorrupted(.init(
                codingPath: [],
                debugDescription: "Date string does not match any of the expected formats"))
        }
    }

    
    public func getGreeting(name: String?) async throws -> String? {
        let client = Client(
            serverURL: URL(string: "https://nheko.io/api")!,
            configuration: .init(dateTranscoder: ExtendedISO8601DateTranscoder()),
            transport: URLSessionTransport()
        )

        //let input = Operations.notes_timeline.Input(
        //    body: Operations.notes_timeline.Input.Body.json(Operations.notes_timeline.Input.Body.jsonPayload(limit: 10, sinceDate: 0, withReplies: true)))
        let response = try await client.notes_local_hyphen_timeline(Operations.notes_local_hyphen_timeline.Input(body: Operations.notes_local_hyphen_timeline.Input.Body.json(Operations.notes_local_hyphen_timeline.Input.Body.jsonPayload(withFiles: false, excludeNsfw: true, sinceDate: 0, withReplies: true))))
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let greeting):
                //return greeting.first!.text
                return try greeting.first!.user.name
            }
        case .undocumented(statusCode: let statusCode, _):
            return "🙉 \(statusCode)"
        case .unauthorized(_):
            return "unauthorized"
        case .badRequest(_):
            return "bad request"
        case .forbidden(_):
            return "4bidden"
        case .internalServerError(_):
            return "500"
        case .code418(_):
            return "🫖"

        }
    }
}
