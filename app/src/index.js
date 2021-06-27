import Web3 from "web3";
import starNotaryArtifact from "../../build/contracts/StarNotary.json";

const App = {
  web3: null,
  account: null,
  meta: null,

  start: async function() {
    const { web3 } = this;
    try {
      // get contract instance
      const networkId = await web3.eth.getChainId();
      console.log(networkId);
      const deployedNetwork = starNotaryArtifact.networks[networkId];
      console.log(deployedNetwork);
      this.meta = new web3.eth.Contract(starNotaryArtifact.abi,deployedNetwork.address);
      const accounts = await web3.eth.getAccounts();
      this.account = accounts[0];
    } catch (error) {
      console.error("Could not connect to contract or chain.");
    }
    /* try {
      // get contract instance
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = starNotaryArtifact.networks[networkId];
      this.meta = new web3.eth.Contract(
        starNotaryArtifact.abi,
        deployedNetwork.address,
      );
      // get accounts
      const accounts = await web3.eth.getAccounts();
      this.account = accounts[0];
    } catch (error) {
      console.error("Could not connect to contract or chain.");
    } */
  },

  setStatus: function(message) {
    const status = document.getElementById("status");
    status.innerHTML = message;
  },

  createStar: async function() {
    try{
      const name = document.getElementById("starName").value;
      const id = document.getElementById("starId").value;
      console.log(this.account);
      await this.meta.methods.createStar(name, id).send({from: this.account});
    
          App.setStatus("New Star Owner is " + this.account + ".");
        }
          catch(error){
            console.error(error.message);
          }
    
  },
  
  // Implement Task 4 Modify the front end of the DAPP
  lookUp: async function (){
    try {
      const id = Number(document.getElementById("lookid").value);
    const result = await this.meta.methods.lookUptokenIdToStarInfo(id).call() 
    App.setStatus(`Star with ID ${id} is ${result}`);
      }
      catch(error){
      console.error(error.message);
    }
    
    
  }

};

window.App = App;

window.addEventListener("load", async function() {
   if (window.ethereum) {
    // use MetaMask's provider
    App.web3 = new Web3(window.ethereum);
    await window.ethereum.enable(); // get permission to access accounts
    
  } else { 
    console.warn("No web3 detected. Falling back to http://localhost:8545. You should remove this fallback when you deploy live",);
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    App.web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"),);
 }

  App.start();
});