require('babel-register');
require('babel-polyfill');

module.exports = {
    networks: {
        development: {
            host: 'higia.blockchain.ganache',
            port: 8545,
            network_id: '*'
        },
    },
    contracts_directory: '/home/app/contracts/',
    contracts_build_directory: '/home/app/abis/',
    compilers: {
        solc: {
            version: '^0.8.2',
            optimizer: {
                enabled: true,
                runs: 200
            }
        }
    }

}