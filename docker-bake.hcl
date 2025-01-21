group "default" {
  targets = ["dagster-core"]
}

target "dagster-core" {
  context = "."
  platforms = ["linux/amd64", "linux/arm64"]
  tags = [
    "ghcr.io/ali2kan/sira-dagster-core:multiarch",
    "ghcr.io/ali2kan/sira-dagster-core:latest"
  ]
  cache-from = ["type=registry,ref=ghcr.io/ali2kan/sira-dagster-core:buildcache"]
  cache-to = ["type=registry,ref=ghcr.io/ali2kan/sira-dagster-core:buildcache,mode=max"]
  args = {
    BUILDKIT_INLINE_CACHE = "1"
  }
}
