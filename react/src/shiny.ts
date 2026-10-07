// Typed access to the shinyreact bridge (window.shinyreact). The R server and
// this client meet only at input / output ids and JSON.
import type { ComponentType, HTMLAttributes, ReactNode } from "react";

type InputOptions = { debounceMs?: number; priority?: "event" | "deferred"; type?: string };
type Status = "pending" | "ready" | "recalculating" | "error";

interface ShinyReactGlobal {
  useShinyInput: <T>(id: string, defaultValue: T, opts?: InputOptions) => [T, (v: T) => void];
  useSetShinyInput: <T>(id: string, defaultValue: T, opts?: InputOptions) => (v: T) => void;
  useShinyInputValue: <T>(id: string) => T | undefined;
  useShinyOutputValue: <T>(id: string, defaultValue?: T) => T | undefined;
  useShinyOutputStatus: (id: string) => Status;
  useShinyOutputError: (id: string) => { message: string } | null;
  useShinyMessageHandler: <T>(id: string, fn: (msg: T) => void) => void;
  useShinyInitialized: () => boolean;
  useShinyBusy: () => boolean;
  ShinyOutput: ComponentType<{ id: string; className?: string; tagName?: string; children?: ReactNode } & HTMLAttributes<HTMLElement>>;
  ImageOutput: ComponentType<{ id: string; className?: string }>;
}

const sr = (window as unknown as { shinyreact: ShinyReactGlobal }).shinyreact;

export const {
  useShinyInput, useSetShinyInput, useShinyInputValue, useShinyOutputValue, useShinyOutputStatus,
  useShinyOutputError, useShinyMessageHandler, useShinyInitialized, useShinyBusy, ShinyOutput, ImageOutput,
} = sr;

/** A React button for Shiny: counts clicks from 0, sent as an event (the server ignores the initial 0). */
export function useShinyButton(id: string): () => void {
  const [n, setN] = sr.useShinyInput<number>(id, 0, { debounceMs: 0, priority: "event" });
  return () => setN(n + 1);
}
