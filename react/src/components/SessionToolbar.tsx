// The session toolbar in the navbar (R/mod_session_manager.R, module
// "session_manager_1"): Refresh MODA (when the data came from a MODA form),
// Save, New, Load, Clear. Every dialog behind them stays Shiny's (showModal()).
//
//   <SessionToolbar t={t} />
//
// Props
//   ns   the module id (default "session_manager_1"): buttons `${ns}-btn_sync_moda`,
//        `${ns}-btn_save_session`, `${ns}-btn_new_session`, `${ns}-btn_load_session`,
//        `${ns}-btn_clear_session`; `${ns}-toolbar` says whether MODA applies
//   t    translator (optional)
//
// The restore prompt shown at start-up is the server's renderUI
// (`${ns}-restore_modal_container`, which calls showModal()), hosted here.
import { FilePlus2, FolderOpen, RefreshCw, Save, Trash2 } from "lucide-react";
import { useShinyOutputValue } from "@/shiny";
import { ActionButton, HostedUI } from "@/lib/inputs";

export function SessionToolbar({ ns = "session_manager_1", t = (s) => s }: { ns?: string; t?: (s: string) => string }) {
  const id = (x: string) => `${ns}-${x}`;
  const state = useShinyOutputValue<{ moda: boolean }>(id("toolbar"));
  const lab = (s: string) => <span className="action-label">{t(s)}</span>;
  return (
    <div className="session-toolbar d-flex align-items-center gap-2">
      <span style={{ fontSize: 15 }}>{t("Session")}</span>
      <div className="btn-group" role="group" aria-label={t("Session controls")}>
        {state?.moda ? (
          <ActionButton id={id("btn_sync_moda")} label={lab("Refresh MODA")} icon={<RefreshCw size={13} />}
                        title={t("Fetch only the MODA submissions that are not in this session yet")} />
        ) : null}
        <ActionButton id={id("btn_save_session")} label={lab("Save")} icon={<Save size={13} />} title={t("Save session")} />
        <ActionButton id={id("btn_new_session")} label={lab("New")} icon={<FilePlus2 size={13} />} title={t("Save this session and start a fresh one")} />
        <ActionButton id={id("btn_load_session")} label={lab("Load")} icon={<FolderOpen size={13} />} title={t("Load a saved session")} />
        <ActionButton id={id("btn_clear_session")} label={lab("Clear")} icon={<Trash2 size={13} />} title={t("Delete saved sessions")} />
      </div>
      <HostedUI id={id("restore_modal_container")} inline />
    </div>
  );
}

export default SessionToolbar;
