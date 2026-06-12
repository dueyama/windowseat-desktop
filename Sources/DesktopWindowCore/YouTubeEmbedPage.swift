import Foundation

public enum YouTubeEmbedPage {
    public static func html(source: ScenicSource) -> String {
        html(
            videoID: source.youtubeVideoID,
            fillMode: source.fillMode,
            muted: source.muted,
            preferredQuality: source.preferredQuality,
            syncToLiveEdge: source.sourceKind == .live,
            overlay: source.showOverlay ? overlayHTML(for: source) : ""
        )
    }

    public static func html(videoID: YouTubeVideoID, fillMode: FillMode) -> String {
        html(
            videoID: videoID,
            fillMode: fillMode,
            muted: true,
            preferredQuality: .highres,
            syncToLiveEdge: false,
            overlay: ""
        )
    }

    private static func html(
        videoID: YouTubeVideoID,
        fillMode: FillMode,
        muted: Bool,
        preferredQuality: PlaybackQuality,
        syncToLiveEdge: Bool,
        overlay: String
    ) -> String {
        let fitClass = fillMode.rawValue
        let mutedValue = muted ? "true" : "false"
        let preferredQualityValue = preferredQuality.rawValue
        let syncToLiveEdgeValue = syncToLiveEdge ? "true" : "false"

        return """
        <!doctype html>
        <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <style>
            html, body {
              width: 100%;
              height: 100%;
              margin: 0;
              overflow: hidden;
              background: #000;
            }

            #player {
              position: absolute;
              top: 50%;
              left: 50%;
              transform: translate(-50%, -50%);
              background: #000;
            }

            body.fill #player {
              width: 100vw;
              height: 56.25vw;
              min-width: 177.7778vh;
              min-height: 100vh;
            }

            body.fit #player {
              width: min(100vw, 177.7778vh);
              height: min(56.25vw, 100vh);
            }

            .agent-note {
              position: fixed;
              left: max(24px, env(safe-area-inset-left));
              bottom: max(22px, env(safe-area-inset-bottom));
              max-width: min(560px, calc(100vw - 48px));
              padding: 16px 18px;
              border-radius: 8px;
              background: rgba(8, 10, 12, 0.58);
              color: #fff;
              font: 14px -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
              line-height: 1.48;
              text-shadow: 0 1px 2px rgba(0, 0, 0, 0.42);
              pointer-events: none;
              -webkit-backdrop-filter: blur(18px) saturate(1.15);
              backdrop-filter: blur(18px) saturate(1.15);
            }

            .agent-note h1 {
              margin: 0 0 6px;
              font-size: 17px;
              font-weight: 650;
            }

            .agent-note p {
              margin: 0;
              color: rgba(255, 255, 255, 0.86);
            }

            .agent-note blockquote {
              margin: 10px 0 0;
              color: rgba(255, 255, 255, 0.76);
              font-size: 13px;
            }

            .agent-note footer {
              margin-top: 4px;
              color: rgba(255, 255, 255, 0.58);
            }

            .playback-error {
              position: fixed;
              inset: 0;
              display: none;
              background: #000;
            }

            .playback-error.is-visible {
              display: block;
            }

            body.playback-failed #player {
              display: none;
            }
          </style>
        </head>
        <body class="\(fitClass)">
          <div id="player"></div>
          \(overlay)
          <div id="playback-error" class="playback-error" aria-hidden="true"></div>
          <script src="https://www.youtube.com/iframe_api"></script>
          <script>
            let player;
            const initialMuted = \(mutedValue);
            const preferredQuality = '\(preferredQualityValue)';
            const shouldSyncToLiveEdge = \(syncToLiveEdgeValue);
            let liveEdgeSyncAttempts = 0;
            let liveEdgeSyncCompleted = false;
            let liveEdgeSyncTimer = null;

            function showPlaybackError() {
              document.body.classList.add('playback-failed');
              const error = document.getElementById('playback-error');
              if (error) {
                error.classList.add('is-visible');
              }
            }

            function requestPreferredQuality(target) {
              if (!target || preferredQuality === 'auto') {
                return;
              }

              if (typeof target.setPlaybackQuality === 'function') {
                target.setPlaybackQuality(preferredQuality);
              }
            }

            function scheduleLiveEdgeSync(target) {
              if (!shouldSyncToLiveEdge || liveEdgeSyncCompleted || liveEdgeSyncAttempts >= 10 || liveEdgeSyncTimer !== null) {
                return;
              }

              const delay = liveEdgeSyncAttempts === 0 ? 0 : 700;
              liveEdgeSyncAttempts += 1;
              liveEdgeSyncTimer = window.setTimeout(function() {
                liveEdgeSyncTimer = null;
                syncToLiveEdge(target);
              }, delay);
            }

            function syncToLiveEdge(target) {
              if (!target || !shouldSyncToLiveEdge || liveEdgeSyncCompleted) {
                return;
              }

              if (typeof target.getDuration !== 'function' || typeof target.seekTo !== 'function') {
                return;
              }

              const duration = Number(target.getDuration());
              if (!Number.isFinite(duration) || duration <= 0) {
                scheduleLiveEdgeSync(target);
                return;
              }

              const currentTime = typeof target.getCurrentTime === 'function'
                ? Number(target.getCurrentTime())
                : 0;
              const currentTimeValue = Number.isFinite(currentTime) ? currentTime : 0;
              const liveEdgeSeconds = Math.max(0, duration - 1);

              if (liveEdgeSeconds - currentTimeValue > 3) {
                target.seekTo(liveEdgeSeconds, true);
              }

              if (typeof target.playVideo === 'function') {
                target.playVideo();
              }

              liveEdgeSyncCompleted = true;
            }

            function onYouTubeIframeAPIReady() {
              player = new YT.Player('player', {
                videoId: '\(videoID.rawValue)',
                playerVars: {
                  autoplay: 1,
                  controls: 0,
                  rel: 0,
                  playsinline: 1,
                  iv_load_policy: 3,
                  vq: preferredQuality
                },
                events: {
                  onReady: function(event) {
                    requestPreferredQuality(event.target);
                    if (initialMuted) {
                      event.target.mute();
                    } else {
                      event.target.unMute();
                    }
                    event.target.playVideo();
                    scheduleLiveEdgeSync(event.target);
                  },
                  onError: function(event) {
                    showPlaybackError();
                  },
                  onStateChange: function(event) {
                    if (event.data === YT.PlayerState.PLAYING || event.data === YT.PlayerState.BUFFERING) {
                      requestPreferredQuality(event.target);
                      scheduleLiveEdgeSync(event.target);
                    }
                  }
                }
              });
            }

            window.desktopWindowSetMuted = function(muted) {
              if (!player || typeof player.mute !== 'function') {
                return;
              }

              if (muted) {
                player.mute();
              } else {
                player.unMute();
              }
            };
          </script>
        </body>
        </html>
        """
    }

    public static func placeholder(message: String) -> String {
        let escapedMessage = htmlEscaped(message)

        return """
        <!doctype html>
        <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <style>
            html, body {
              width: 100%;
              height: 100%;
              margin: 0;
              background: #0b0d10;
              color: #f4f7fb;
              font: 15px -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            }

            body {
              display: grid;
              place-items: center;
            }

            main {
              max-width: 560px;
              padding: 24px;
              text-align: center;
              line-height: 1.5;
            }

            h1 {
              margin: 0 0 8px;
              font-size: 22px;
              font-weight: 650;
            }

            p {
              margin: 0;
              color: #b9c2d0;
            }
          </style>
        </head>
        <body>
          <main>
            <h1>WindowSeat</h1>
            <p>\(escapedMessage)</p>
          </main>
        </body>
        </html>
        """
    }

    private static func htmlEscaped(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }

    private static func overlayHTML(for source: ScenicSource) -> String {
        guard source.agentNote != nil || source.quote != nil else {
            return ""
        }

        var parts: [String] = []

        if let note = source.agentNote {
            parts.append("<h1>\(htmlEscaped(note.headline))</h1>")
            parts.append("<p>\(htmlEscaped(note.body))</p>")
        }

        if let quote = source.quote {
            let attribution = quote.attribution.map { "<footer>\(htmlEscaped($0))</footer>" } ?? ""
            parts.append("<blockquote>\(htmlEscaped(quote.text))\(attribution)</blockquote>")
        }

        return "<section class=\"agent-note\">\(parts.joined())</section>"
    }
}
