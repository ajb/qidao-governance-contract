const glob = require('glob')
const find = require('lodash.find')

const abis = []

glob('./abi/*.json', (_, files) => {
  for (const f of files) {
    abis.push(require(f))
  }

  const uniqueFunctions = []

  for (const abi of abis) {
    for (const component of abi) {
      if (component.type !== 'function') continue
      if (component.stateMutability === 'view') continue

      const found = find(uniqueFunctions, (existing) => existing.name === component.name && existing.inputs.length === component.inputs.length)
      if (found) continue

      uniqueFunctions.push(component)
    }
  }

  console.log(JSON.stringify(uniqueFunctions, null, 2))
})
