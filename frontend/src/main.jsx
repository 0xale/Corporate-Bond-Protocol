import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App.jsx";
import "./index.css";
import { WagmiConfig, createConfig } from "wagmi";
import {
  ConnectKitProvider,
  ConnectKitButton,
  getDefaultConfig,
} from "connectkit";

const alchemyID = "1jLRfHRMjYl-cC4LW1i5fhIcSRQMdABC";

const config = createConfig(
  getDefaultConfig({
    // Required API Keys
    alchemyId: alchemyID,

    // Required
    appName: "Corporate Bond Protocol",

    // Optional
    appDescription: "Your App Description",
    appUrl: "https://family.co", // your app's url
    appIcon: "https://family.co/logo.png", // your app's icon, no bigger than 1024x1024px (max. 1MB)
  })
);

ReactDOM.createRoot(document.getElementById("root")).render(
  <WagmiConfig config={config}>
    <ConnectKitProvider>
      <App />
    </ConnectKitProvider>
  </WagmiConfig>
);
