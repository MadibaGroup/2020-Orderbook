const selfdestruct = artifacts.require('selfdestruct.sol');

contract('selfdestruct', function(accounts){
  it('should selfdestruct', async function(){
    const instance = await selfdestruct.deployed();
    try {
      await instance.destroy();
      console.log('Success')
    } catch(err){
      console.log('Failure: ' + err);
    }
  });
})