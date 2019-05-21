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
    return await App.initContract();
  },

  initContract:async function() {
    $.getJSON('ChickenStore.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
      var ChickenStoreArtifact = data;
      App.contracts.ChickenStore = TruffleContract(ChickenStoreArtifact);

      // Set the provider for our contract
      App.contracts.ChickenStore.setProvider(App.web3Provider);

      // Use our contract to retrieve and mark the adopted pets
      //return App.transactionOfChicken();
    });

    return App.bindEvents();
  },


  bindEvents: function() {
    $("#account").html(web3.eth.accounts[0]);
    App.getEachChicken();
    //popInfo
    $(document).on('click', '.btn-popInfo', App.popSellerInfo);
    //closeInfo
    $(document).on('click', '.btn-closeInfo', App.closeInfo);

    $(document).on('click', '.btn-buy', App.buyChicken);


  },

  buyChicken:function(){
    alert("buy");
  },

  popSellerInfo:function(){
    $("#dialog_div").css("display","inline");
  },
  closeInfo:function(){
    $("#dialog_div").css("display","none");
  },
  accountContent:function(){
    $("#account_div").css("display","inline");
  },

  cAI:function(){
    $("#account_div").css("display","none");
  },

  getEachChicken:function(){

    var chickenStore;
    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.ChickenStore.deployed().then(function(instance) {
        chickenStore = instance;
        return chickenStore.numberOfSeller.call();
      }).then(function(result) {
          for(i=1;i<=result;i++){
            App.getChickenByNumber(i)
          }
        }

      ).catch(function(err) {
        console.log(err.message);
      });


    });

  },

  getChickenByNumber:function(num){

    var chickenStore;
    web3.eth.getAccounts(function(error, accounts) {
    if (error) {
      console.log(error);
    }
    var account = accounts[0];
    App.contracts.ChickenStore.deployed().then(function(instance) {
      chikenStore = instance;
      return chikenStore.getChickenInformation(num);
    }).then(function(result) {
          // alert(result[3]);
          console.log(result);
          var chickensRow = $('#chickensRow');
          var chickenTemplate = $('#chickenTemplate');
          chickenTemplate.find('.img-src').attr("src",result[3]);
          chickenTemplate.find('.panel-title').text(result[2]);
          chickenTemplate.find('.chicken-service').text(result[4]);
          chickenTemplate.find('.chicken-price').text(result[5].toString(10));
          chickenTemplate.find('.chicken-address').text(result[1]);
          chickensRow.append(chickenTemplate.html());
          chickenResult=result;

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
