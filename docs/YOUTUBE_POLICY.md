# YouTube Policy Notes

WindowSeat should use YouTube as an embedded playback surface, not as a media extraction source.

The practical rule for this repository:

- Allowed direction: official YouTube iframe/player embedding.
- Avoided direction: downloading, backing up, caching, storing, transcoding, recording, or extracting frames from YouTube audiovisual content.

Relevant official documents:

- YouTube API Services Terms of Service: https://developers.google.com/youtube/terms/api-services-terms-of-service
- YouTube API Services Developer Policies: https://developers.google.com/youtube/terms/developer-policies
- YouTube IFrame Player API: https://developers.google.com/youtube/iframe_api_reference

If a future implementation needs source discovery, use YouTube Data API metadata. Do not use stream URL extraction tools for YouTube.

For non-YouTube cameras, prefer sources that explicitly publish public HLS or MJPEG endpoints and document permitted use.
