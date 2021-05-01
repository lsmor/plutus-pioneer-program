{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE DeriveAnyClass    #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications  #-}
{-# LANGUAGE TypeOperators     #-}

module Week04.Homework where

import Data.Aeson                 (FromJSON, ToJSON)
import Data.Functor               (void)
import Data.Text                  (Text, unpack)
import GHC.Generics               (Generic)
import Ledger
import Ledger.Ada                 as Ada
import Ledger.Constraints         as Constraints
import Plutus.Contract            as Contract
import Plutus.Trace.Emulator      as Emulator
import Wallet.Emulator.Wallet
import Control.Monad (forever)


data PayParams = PayParams
    { ppRecipient :: PubKeyHash
    , ppLovelace  :: Integer
    } deriving (Show, Generic, FromJSON, ToJSON)

type PaySchema = BlockchainActions .\/ Endpoint "pay" PayParams

payContract :: Contract () PaySchema Text ()
payContract = forever $ do
    pp <- endpoint @"pay"
    let tx = mustPayToPubKey (ppRecipient pp) $ lovelaceValueOf $ ppLovelace pp
    void $ submitTx tx

payContractHandle :: Contract () PaySchema Text ()
payContractHandle = forever $ do
    pp <- endpoint @"pay"
    let tx = mustPayToPubKey (ppRecipient pp) $ lovelaceValueOf $ ppLovelace pp
        errorHandler = \t -> Contract.logInfo @Text ("Error submiting the trasaction!: " <> t)
    -- Notice that errors must be handle inside the contract! otherwise, error are detected only once.
    errorHandler `handleError` void (submitTx tx)

-- A trace that invokes the pay endpoint of payContract on Wallet 1 twice, each time with Wallet 2 as
-- recipient, but with amounts given by the two arguments. There should be a delay of one slot
-- after each endpoint call.

-- Modified payTrace so it accept the contract in order to have both versions of the contract in scope (with and without error handler)
payTrace :: Contract () PaySchema Text () -> Integer -> Integer -> EmulatorTrace ()
payTrace c x y = do
    let w2 = Wallet 2
        recipient = pubKeyHash $ walletPubKey w2
        p1 = PayParams recipient x
        p2 = PayParams recipient y
    h1 <- Wallet 1 `activateContractWallet` c
    callEndpoint @"pay" h1 p1
    void $ Emulator.waitNSlots 1
    callEndpoint @"pay" h1 p2
    void $ Emulator.waitNSlots 1

payTest1 :: IO ()
payTest1 = runEmulatorTraceIO $ payTrace payContract 1000000 2000000

payTest2 :: IO ()
payTest2 = runEmulatorTraceIO $ payTrace payContractHandle 1000000000 2000000
