const TrimMirror = artifacts.require("TrimMirror");

contract('TrimMirror', (accounts) => {
    let trimMirror;
    it('deploys and tests TrimMirror', function () {
        return TrimMirror.deployed().then(function (instance) {
            trimMirror = instance;
            return trimMirror.address;
        }).then(function (address) {
            assert.notEqual(address, 0x0, 'has an address...');
            return trimMirror.trimStringMirroringChars(["year", "electricity", "apple"]);
        }).then(function (result) {
            result = result.replace("\u0000", ""); // removes NUL chars - need to debug behaviour : TODO
            assert.equal(result, "appectricitear", 'case # pass...');
            return trimMirror.trimStringMirroringChars(["tree", "must", "museum", "ethereum"]);
        }).then(function (result) {
            result = result.replace("\u0000", ""); // removes NUL chars - need to debug behaviour : TODO
            assert.equal(result, "etheresesree", 'case #2 pass...');
            return trimMirror.trimStringMirroringChars(["rome", "e", "more"]);
        }).then(function (result) {
            result = result.replace("\u0000", ""); // removes NUL chars - need to debug behaviour : TODO
            assert.equal(result, "e", 'case #3 pass...');
        })
    })
})
