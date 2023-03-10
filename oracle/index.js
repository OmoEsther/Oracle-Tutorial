require("dotenv").config();
const ethers = require("ethers");
const axios = require("axios");
const abi = require("./contracts/consumer.abi.json");

const consumerAddress = process.env.CONSUMER_ADDRESS;
const oraclePrivateKey = process.env.PRIVAKE_KEY;

const provider = new ethers.providers.JsonRpcProvider(
  "https://alfajores-forno.celo-testnet.org"
);

const walletSigner = new ethers.Wallet(oraclePrivateKey, provider);

const contract = new ethers.Contract(consumerAddress, abi, walletSigner);

const MAX_RETRIES = 3;

async function getTemperature(lat, log) {
  console.log("Making API Call");
  let temp = 0;
  await axios
    .get(
      `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${log}&current_weather=true`
    )
    .then((res) => {
      temp = res.data.current_weather.temperature;
    })
    .catch((err) => {
      console.log(`ERROR: ${err.message}`);
    });
  return temp.toString();
}

async function sendTemperatureData(requestId, temp) {
  console.log("Sending request response to the blockchain");
  const txn = await contract.rawCompleteRequest(requestId, temp);
  console.log(
    `Request completed for ${requestId} at transaction hash https://explorer.celo.org/alfajores/tx/${txn.hash}`
  );
  console.log(
    "-------------------------------------------------------------------------------------"
  );
}

async function processRequest(request) {
  let retries = 0;
  while (retries < MAX_RETRIES) {
    try {
      const temp = await getTemperature(
        Number(request.lat),
        Number(request.log)
      );
      await sendTemperatureData(request.requestId, temp);
      return;
    } catch (e) {
      if (retries === MAX_RETRIES - 1) {
        console.log("Failed to data from API");
        await sendTemperatureData(request.requestId, "0");
        return;
      }
      retries++;
    }
  }
}

(async () => {
  console.log("Oracle Service Started");
  console.log(
    "-------------------------------------------------------------------------------------"
  );
  contract.on("newRequest", async (requestId, lat, log) => {
    console.log(`New request with id ${requestId} for lat ${lat} lon ${log}`);
    const request = { requestId, lat, log };
    await processRequest(request);
  });
})();
