## [Unreleased]

## [0.6.0] - 2026-08-20

- Add non-streaming and SSE streaming support for the Responses API through `OpenAI::Client#create_response`.

## [0.5.6] - 2026-08-15

- Preserve complete error response bodies when streamed HTTP errors arrive in multiple chunks.

## [0.5.5] - 2026-08-03

- Avoid mutating request parameters in chat completion and speech requests, including frozen nested schemas.

## [0.1.0] - 2023-02-14

- Initial release
