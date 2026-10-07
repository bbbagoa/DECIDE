import "@/app.css";
import App from "@/App";

const { ReactDOM } = (window as unknown as { shinyreact: { ReactDOM: { createRoot: (el: Element) => { render: (n: unknown) => void } } } }).shinyreact;

ReactDOM.createRoot(document.body.appendChild(document.createElement("div"))).render(<App />);
