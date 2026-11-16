// Flat config, non-type-checked presets: fast and CI-friendly.
// TypeScript is held at 6.x in package.json because typescript-eslint does not
// support the native 7.x compiler yet; lift the pin when its peer range allows.
import js from "@eslint/js";
import { defineConfig, globalIgnores } from "eslint/config";
import tseslint from "typescript-eslint";

export default defineConfig(
  globalIgnores(["dist/**", "coverage/**"]),
  js.configs.recommended,
  tseslint.configs.recommended,
  {
    rules: {
      // AGENTS.md permits `any` only with a `// why:` comment. Warn rather than
      // block so the comment, not the linter, is the gate.
      "@typescript-eslint/no-explicit-any": "warn",
      "@typescript-eslint/no-unused-vars": [
        "warn",
        { argsIgnorePattern: "^_", varsIgnorePattern: "^_" },
      ],
    },
  },
);
