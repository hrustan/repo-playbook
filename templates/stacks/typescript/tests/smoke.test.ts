import { expect, test } from "vitest";

import { ready } from "../src/index";

// Proves the toolchain is wired. Delete once a real test exists.
test("toolchain is wired", () => {
  expect(ready).toBe(true);
});
