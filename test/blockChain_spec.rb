require_relative '../src/blockchain.rb'

describe Block do

	describe "#initialize" do
	    context "given the input index, proof and previousHash, new " do
	        StartTime = Time.now
            block = Block.new(index: 0, proof: 1, previousHash: 2)
	        it "shall initialize the block" do
	            expect(block.index).to eql(0)
  	            expect(block.proof).to eql(1)
  	            expect(block.previousHash).to eql(2)
	        end
            it "shall have a timeStamp between Start and now" do
                expect(block.timeStamp).to be_between(StartTime, Time.now)
            end	        
	    end        
    end
    
    describe "#newTransaction" do 
        block = Block.new(index: 0, proof: 1, previousHash: 2)
        context "a new transaction" do
            it "shall be stored in the block" do
                block.newTransaction(sender: 3, recipient: 4, amount: 5)
                expect(block.transactions.length).to eql(1)
            end
            it "shall store the specified input" do
                expect(block.transactions.last[:sender]).to eql(3)
                expect(block.transactions.last[:recipient]).to eql(4)
                expect(block.transactions.last[:amount]).to eql(5)
            end
        end
        context "a second transaction" do
            it "shall also be stored in the block" do
                block.newTransaction(sender: 6, recipient: 7, amount: 8)
                expect(block.transactions.length).to eql(2)
                expect(block.transactions.last[:sender]).to eql(6)
                expect(block.transactions.last[:recipient]).to eql(7)
                expect(block.transactions.last[:amount]).to eql(8)                
             end
        end            
    end
    
    describe "#hash256" do
	    context "

    
end

describe BlockChain do
	describe "#initialize and lastblock" do
	    context "a new block chain" do
	        it "shall contain the genesis block" do
	            blockChain = BlockChain.new
	            expect(blockChain.lastBlock).to_not eql(nil)
	        end
	    end            
	end
	describe "#chain" do
        blockChain = BlockChain.new
	    context "chain call on new chain" do
	        it "shall return the genesis block" do
	            expect(blockChain.chain.length).to eql(1)
                expect(blockChain.chain.first.proof).to eql(100)
                expect(blockChain.chain.first.previousHash).to eql(1)
                expect(blockChain.chain.first.index).to eql(0)
	        end
	    end
	end
	describe "#newBlock" do
	    context "a newBlock " do
	        it "shall add a new block to the chain" do
                blockChain = BlockChain.new 
                blockChain.newBlock(proof: 1000, previousHash: 10)
	            expect(blockChain.chain.length).to eql(2)
                expect(blockChain.chain[1].proof).to eql(1000)
                expect(blockChain.chain[1].previousHash).to eql(10)
                expect(blockChain.chain[1].index).to eql(1)
	        end
	    end
	end
end
