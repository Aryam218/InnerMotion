//
//  GiminiService.swift
//  InnerMotion
//
//  Created by Aryam Almutairi on 28/02/1448 AH.
//

import Foundation


// MARK: - Gemini Service

final class GeminiService {

    static let shared = GeminiService()

    private init() {}


    // MARK: - Model

    private let modelName =
        "gemini-3.6-flash"


    // MARK: - Generate Structured JSON

    func generateJSON(
        systemInstruction: String,
        prompt: String
    ) async throws -> String {

        guard
            !Secrets.geminiAPIKey
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .isEmpty
        else {

            throw GeminiServiceError
                .missingAPIKey
        }


        // MARK: - Endpoint

        guard let url = URL(
            string:
                """
                https://generativelanguage.googleapis.com/v1beta/models/\(modelName):generateContent
                """
        ) else {

            throw GeminiServiceError
                .invalidURL
        }


        // MARK: - Request

        var request =
            URLRequest(
                url: url
            )

        request.httpMethod =
            "POST"

        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Content-Type"
        )

        request.setValue(
            Secrets.geminiAPIKey,
            forHTTPHeaderField:
                "x-goog-api-key"
        )


        // MARK: - Request Body

        let body =
            GeminiRequest(
                systemInstruction:
                    GeminiContent(
                        parts: [
                            GeminiPart(
                                text:
                                    systemInstruction
                            )
                        ]
                    ),

                contents: [
                    GeminiContent(
                        parts: [
                            GeminiPart(
                                text:
                                    prompt
                            )
                        ]
                    )
                ],

                generationConfig:
                    GeminiGenerationConfig(
                        responseMimeType:
                            "application/json"
                    )
            )


        // MARK: - Encode Body

        do {

            request.httpBody =
                try JSONEncoder()
                    .encode(
                        body
                    )

        } catch {

            throw GeminiServiceError
                .encodingFailed(
                    error
                )
        }


        // MARK: - Send Request

        let data: Data
        let response: URLResponse

        do {

            (
                data,
                response
            ) =
                try await
                URLSession
                    .shared
                    .data(
                        for:
                            request
                    )

        } catch {

            throw GeminiServiceError
                .networkError(
                    error
                )
        }


        // MARK: - Validate HTTP Response

        guard let httpResponse =
                response
                as? HTTPURLResponse
        else {

            throw GeminiServiceError
                .invalidResponse
        }


        guard (200...299).contains(httpResponse.statusCode) else {

            let message =
                String(
                    data: data,
                    encoding: .utf8
                )
                ??
                "Unknown Gemini API error."

            print(
                """
                Gemini API Error
                Status:
                \(httpResponse.statusCode)

                Response:
                \(message)
                """
            )

            throw GeminiServiceError
                .apiError(
                    statusCode:
                        httpResponse
                            .statusCode,
                    message:
                        message
                )
        }


        // MARK: - Decode Gemini Response

        let decodedResponse:
            GeminiResponse

        do {

            decodedResponse =
                try JSONDecoder()
                    .decode(
                        GeminiResponse.self,
                        from: data
                    )

        } catch {

            let rawResponse =
                String(
                    data: data,
                    encoding: .utf8
                )
                ??
                "Unable to read raw response."

            print(
                """
                Failed to decode Gemini response.

                Raw response:
                \(rawResponse)
                """
            )

            throw GeminiServiceError
                .decodingFailed(
                    error
                )
        }


        // MARK: - Extract Text

        guard
            let text =
                decodedResponse
                    .candidates
                    .first?
                    .content
                    .parts
                    .first?
                    .text
        else {

            throw GeminiServiceError
                .emptyResponse
        }


        return text
    }
}


// MARK: - Gemini Request Models

private struct GeminiRequest:
    Encodable {

    let systemInstruction:
        GeminiContent

    let contents:
        [GeminiContent]

    let generationConfig:
        GeminiGenerationConfig
}


private struct GeminiContent:
    Codable {

    let parts:
        [GeminiPart]
}


private struct GeminiPart:
    Codable {

    let text:
        String
}


private struct GeminiGenerationConfig:
    Encodable {

    let responseMimeType:
        String
}


// MARK: - Gemini Response Models

private struct GeminiResponse:
    Decodable {

    let candidates:
        [GeminiCandidate]
}


private struct GeminiCandidate:
    Decodable {

    let content:
        GeminiContent
}


// MARK: - Errors

enum GeminiServiceError:
    LocalizedError {

    case missingAPIKey

    case invalidURL

    case encodingFailed(
        Error
    )

    case networkError(
        Error
    )

    case invalidResponse

    case apiError(
        statusCode: Int,
        message: String
    )

    case decodingFailed(
        Error
    )

    case emptyResponse


    var errorDescription:
        String? {

        switch self {

        case .missingAPIKey:

            return
                "Gemini API key is missing."

        case .invalidURL:

            return
                "The Gemini API URL is invalid."

        case .encodingFailed(
            let error
        ):

            return
                """
                Failed to prepare the Gemini request:
                \(error.localizedDescription)
                """

        case .networkError(
            let error
        ):

            return
                """
                Failed to connect to Gemini:
                \(error.localizedDescription)
                """

        case .invalidResponse:

            return
                "Gemini returned an invalid response."

        case .apiError(
            let statusCode,
            let message
        ):

            return
                """
                Gemini API error (\(statusCode)):
                \(message)
                """

        case .decodingFailed(
            let error
        ):

            return
                """
                Failed to decode Gemini response:
                \(error.localizedDescription)
                """

        case .emptyResponse:

            return
                "Gemini returned an empty response."
        }
    }
}
