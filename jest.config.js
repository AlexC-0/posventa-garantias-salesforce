const { jestConfig } = require('@salesforce/sfdx-lwc-jest/config');
module.exports = {
    ...jestConfig,
    // sfdx-lwc-jest 8 resuelve "lwc" al main ESM; Jest 29 necesita la distribución CJS oficial.
    moduleNameMapper: { '^lwc$': require.resolve('@lwc/engine-dom/dist/index.cjs') },
    testPathIgnorePatterns: ['<rootDir>/.local/', '<rootDir>/node_modules/']
};
