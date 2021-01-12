"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ArbConversion = void 0;
var utils_1 = require("ethers/utils");
// TODO async generator that pulls constants from contracts
var ArbConversion = /** @class */ (function () {
    function ArbConversion(ticksPerBlock, secondsPerBlock, gasPerSecond, gasPerStep) {
        if (ticksPerBlock === void 0) { ticksPerBlock = utils_1.bigNumberify(1000); }
        if (secondsPerBlock === void 0) { secondsPerBlock = utils_1.bigNumberify(13); }
        if (gasPerSecond === void 0) { gasPerSecond = Math.pow(10, 8); }
        if (gasPerStep === void 0) { gasPerStep = 5; }
        this.ticksPerBlock = ticksPerBlock;
        this.secondsPerBlock = secondsPerBlock;
        this.gasPerSecond = gasPerSecond;
        this.gasPerStep = gasPerStep;
    }
    ArbConversion.prototype.blocksToSeconds = function (blocks) {
        return this.secondsPerBlock.mul(blocks);
    };
    ArbConversion.prototype.blocksToTicks = function (blocks) {
        return this.ticksPerBlock.mul(blocks);
    };
    ArbConversion.prototype.ticksToBlocks = function (ticks) {
        return ticks.div(this.ticksPerBlock);
    };
    ArbConversion.prototype.ticksToSeconds = function (ticks) {
        return this.blocksToSeconds(this.ticksToBlocks(ticks));
    };
    ArbConversion.prototype.secondsToBlocks = function (seconds) {
        return utils_1.bigNumberify(seconds).div(this.secondsPerBlock);
    };
    ArbConversion.prototype.secondsToTicks = function (seconds) {
        return this.blocksToTicks(this.secondsToBlocks(seconds));
    };
    ArbConversion.prototype.cpuFactorToSpeedLimitSecs = function (factor) {
        return factor * this.gasPerSecond;
    };
    ArbConversion.prototype.speedLimitSecsToCpuFactor = function (seconds) {
        return seconds / this.gasPerSecond;
    };
    ArbConversion.prototype.assertionTimeToSteps = function (seconds, speedLimitSeconds) {
        return (seconds * speedLimitSeconds) / this.gasPerStep;
    };
    ArbConversion.prototype.stepsToAssertionTime = function (steps, speedLimitSeconds) {
        return (steps * this.gasPerStep) / speedLimitSeconds;
    };
    return ArbConversion;
}());
exports.ArbConversion = ArbConversion;
