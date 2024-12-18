import { buildModule } from '@nomicfoundation/hardhat-ignition/modules';

const PropertyTokenModule = buildModule('PropertyTokenModule', (m) => {
  // Define parameters for deployment
  const name = m.getParameter<string>('name', 'PropertyToken');
  const symbol = m.getParameter<string>('symbol', 'PTKN');
  const admin = m.getAccount(0);

  // Deploy the PropertyToken contract
  const propertyToken = m.contract('PropertyToken', [name, symbol, admin]);

  return { propertyToken };
});

export default PropertyTokenModule;
