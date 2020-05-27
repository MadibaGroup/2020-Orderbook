const ObjectFactory = artifacts.require('ObjectFactory');
const Product = artifacts.require('Product');



// contract('ObjectFactory', function(accounts) {
//     it('should create another object', async() => {
//         const ObjectFactoryInstance = await ObjectFactory.deployed(); 
        
//         await ObjectFactoryInstance.
        
//     });

contract('Product', function(accounts) {
    it('should create another object', async() => {
        const ProductInstance = await Product.deployed(); 
        
        await ProductInstance.haveFactoryCreateProductWithReferenceToThis();
        
    });


});