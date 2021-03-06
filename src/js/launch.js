App = {
  web3Provider: null,
  contracts: {},

  init: async function() {
    return await App.initWeb3();
  },

  initWeb3: async function() {
    // Modern dapp browsers...
    if (window.ethereum) {
      App.web3Provider = window.ethereum;
      try {

        // Request account access
        await window.ethereum.enable();
      } catch (error) {
      // User denied account access...
      console.error("User denied account access")
      }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
      App.web3Provider = window.web3.currentProvider;
    }
    // If no injected web3 instance is detected, fall back to Ganache
    else {
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
    }
    web3 = new Web3(App.web3Provider);
    return App.initContract();
  },

  initContract: function() {
    $.getJSON('ChickenStore.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
      var ChickenStoreArtifact = data;
      App.contracts.ChickenStore = TruffleContract(ChickenStoreArtifact);

      // Set the provider for our contract
      App.contracts.ChickenStore.setProvider(App.web3Provider);
    });
    return App.bindEvents();
  },

  bindEvents: function() {
    // $(document).on('click', '.btn-launch', App.addChicken);
    $(".btn-launch").click(App.addChicken);
  },

  addChicken: function(event) {
    event.preventDefault();
    //get_data
    var name=$("#name").val();
    var image=$("#image").val();
    var service=$("#service").val();
    var price=$("#price").val();
    var travelFare=$("#travelFare").val();

    //call soldity function
    var chickenStore;
    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
      var account = accounts[0];
      App.contracts.ChickenStore.deployed().then(function(instance) {
        chikenStore = instance;
        console.log("addChicken");
        console.log(account);
        return chikenStore.launch(name,image,service,price,travelFare,{from:account});
      }).then(function(result) {
        console.log(result);
        return console.log(chikenStore.getChickenInformation(1));
      }).then(function(result) {
        console.log(result);
        return (result);
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  }
};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
