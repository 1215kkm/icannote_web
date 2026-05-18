/// Global runtime flag describing whether Firebase is usable.
///
/// Set once during app start-up in `main()`. When `false`, the app runs in
/// fully-offline mode: the local whiteboard works completely, while cloud
/// features (auth, real-time collaboration, cloud sync) are disabled and
/// surface a clear "cloud not configured" state instead of crashing.
bool isFirebaseReady = false;
