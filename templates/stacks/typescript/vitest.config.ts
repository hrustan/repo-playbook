import { defineConfig } from "vitest/config";

// Tests are hermetic: committed fixtures, injected fakes, never the live
// network. Single `tests/` dir for a single app; per-package `tests/` dirs in a
// monorepo (widen `include` to packages/**, apps/**).
export default defineConfig({
  test: {
    environment: "node",
    include: ["tests/**/*.test.ts"],
  },
});
