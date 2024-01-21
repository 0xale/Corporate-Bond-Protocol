import React from "react";

function Hero() {
  return (
    <section className="bg-gray-900 text-white">
      <div className="mx-auto max-w-screen-xl px-4 py-32 lg:flex lg:h-screen lg:items-center">
        <div className="mx-auto max-w-3xl text-center">
          {/* Corporate Bond Protocol Smart Contract Heading */}
          <h1 className="bg-gradient-to-r from-green-300 via-blue-500 to-purple-600 bg-clip-text text-3xl font-extrabold text-transparent sm:text-5xl">
            Corporate Bond Protocol.
            <span className="sm:block"> Manage Bonds With GHO Tokens </span>
          </h1>

          {/* Corporate Bond Protocol Smart Contract Content */}
          <p className="mx-auto mt-4 max-w-xl sm:text-xl/relaxed">
            The Corporate Bond Protocol is a decentralized smart contract
            deployed on the Ethereum blockchain. It provides a comprehensive
            platform for registered companies to issue bonds, and users can
            seamlessly engage in activities such as bond creation, purchase,
            transfer, and redemption.
          </p>

          {/* Corporate Bond Protocol Smart Contract Call-to-Action Buttons */}
          <div className="mt-8 flex flex-wrap justify-center gap-4">
            <a
              className="block w-full rounded border border-blue-600 bg-blue-600 px-12 py-3 text-sm font-medium text-white hover:bg-transparent hover:text-white focus:outline-none focus:ring active:text-opacity-75 sm:w-auto"
              href="/get-started"
            >
              Get Started
            </a>

            <a
              className="block w-full rounded border border-blue-600 px-12 py-3 text-sm font-medium text-white hover:bg-blue-600 focus:outline-none focus:ring active:bg-blue-500 sm:w-auto"
              href="/about"
            >
              Learn More
            </a>
          </div>
        </div>
      </div>
    </section>
  );
}

export default Hero;
