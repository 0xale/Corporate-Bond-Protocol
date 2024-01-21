import { useState } from "react";

import Hero from "./Components/Hero";
import Navbar from "./Components/Navbar";
import Footer from "./Components/Footer";
import Sections from "./Components/Sections";
function App() {
  const [count, setCount] = useState(0);

  return (
    <>
      <Navbar />
      <Hero />
      <Sections />
      <Footer />
    </>
  );
}

export default App;
