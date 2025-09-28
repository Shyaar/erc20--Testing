import { expect } from "chai";
import { network } from "hardhat";
import { ZeroAddress } from "ethers";

const { ethers } = await network.connect();

describe("TokenContract", () => {
  let erc20Contract: any;
  let owner: any, addr1: any, addr2: any, addr3: any;

  beforeEach(async () => {
    [owner, addr1, addr2, addr3] = await ethers.getSigners();
    erc20Contract = await ethers.deployContract("TokenContract", [
      "BLToken",
      "BLT",
    ]);
  });

  describe("Deployments", () => {
    it("should set constructor dependencies", async () => {
      expect(await erc20Contract.tokenName()).to.equal("BLToken");
      expect(await erc20Contract.tokenSymbol()).to.equal("BLT");
      expect(await erc20Contract.admin()).to.equal(owner.address);
    });

    it("should mint initial supply to contract address", async () => {
      const contractAddr = erc20Contract.target;
      expect(await erc20Contract.balanceOf(contractAddr)).to.equal(10 * 18);
    });
  });

  describe("Mint", () => {
    it("should mint tokens to a valid address", async () => {
      const amount = 500;
      await erc20Contract.connect(owner).mint(addr2, amount);
      expect(await erc20Contract.balanceOf(addr2)).to.equal(amount);
    });

    it("should fail when minting to zero address", async () => {
      await expect(erc20Contract.connect(owner).mint(ZeroAddress, 100))
        .to.be.revertedWithCustomError(erc20Contract, "invalidAccount")
        .withArgs(ZeroAddress);
    });

    it("should fail when minting zero amount", async () => {
      await expect(erc20Contract.connect(owner).mint(addr1, 0))
        .to.be.revertedWithCustomError(erc20Contract, "invalidAmount")
        .withArgs(0);
    });

    it("should update totalSupply after mint", async () => {
      const amount = 200;
      const prevSupply = await erc20Contract.totalSupplyOf();
      await erc20Contract.connect(owner).mint(addr1, amount);
      expect(await erc20Contract.totalSupplyOf()).to.equal(
        prevSupply + BigInt(amount)
      );
    });
  });

  describe("Transactions", () => {
    describe("BalanceOf", () => {
      it("should revert for zero address", async () => {
        await expect(erc20Contract.balanceOf(ZeroAddress))
          .to.be.revertedWithCustomError(erc20Contract, "invalidAccount")
          .withArgs(ZeroAddress);
      });

      it("should return correct balance after mint", async () => {
        const amount = 200;
        await erc20Contract.connect(owner).mint(addr1, amount);
        expect(await erc20Contract.balanceOf(addr1)).to.equal(amount);
      });
    });

    describe("Transfer", () => {
      beforeEach(async () => {
        await erc20Contract.connect(owner).mint(addr2, 200);
      });

      it("should transfer tokens from holder to receiver", async () => {
        await erc20Contract.connect(addr2).transfer(addr1, 200);
        expect(await erc20Contract.balanceOf(addr2)).to.equal(0);
        expect(await erc20Contract.balanceOf(addr1)).to.equal(200);
      });

      it("should fail to transfer to zero address", async () => {
        await expect(erc20Contract.connect(addr2).transfer(ZeroAddress, 200))
          .to.be.revertedWithCustomError(erc20Contract, "invalidAccount")
          .withArgs(ZeroAddress);
      });

      it("should fail to transfer zero amount", async () => {
        await expect(erc20Contract.connect(addr2).transfer(addr1, 0))
          .to.be.revertedWithCustomError(erc20Contract, "invalidAmount")
          .withArgs(0);
      });

      it("should fail to transfer with insufficient balance", async () => {
        await expect(
          erc20Contract.connect(addr3).transfer(addr1, 50)
        ).to.be.revertedWithCustomError(erc20Contract, "insufficientBalance");
      });
    });

    describe("Approve & Allowance", () => {
      it("should approve spender and update allowance", async () => {
        await erc20Contract.connect(addr1).approve(addr2, 300);
        expect(await erc20Contract.allowance(addr1, addr2)).to.equal(300);
      });

      it("should revert approval for zero spender", async () => {
        await expect(erc20Contract.connect(addr1).approve(ZeroAddress, 100))
          .to.be.revertedWithCustomError(erc20Contract, "invalidSpenderAccount")
          .withArgs(ZeroAddress);
      });

      it("should revert allowance for zero owner", async () => {
        await expect(erc20Contract.allowance(ZeroAddress, addr2))
          .to.be.revertedWithCustomError(erc20Contract, "invalidAccount")
          .withArgs(ZeroAddress);
      });

      it("should revert allowance for zero spender", async () => {
        await expect(erc20Contract.allowance(addr1, ZeroAddress))
          .to.be.revertedWithCustomError(erc20Contract, "invalidSpenderAccount")
          .withArgs(ZeroAddress);
      });
    });

    describe("TransferFrom", () => {
      beforeEach(async () => {
        await erc20Contract.connect(owner).mint(addr1, 500);
        await erc20Contract.connect(addr1).approve(addr2, 200);
      });

      it("should allow spender to transfer tokens within allowance", async () => {
        let allowance = await erc20Contract.allowance(addr1, addr2);
        console.log("allowance :", allowance);

        await erc20Contract.connect(addr2).transferFrom(addr1, addr3, 150);

        expect(await erc20Contract.balanceOf(addr1)).to.equal(350);
        expect(await erc20Contract.balanceOf(addr3)).to.equal(150);
        expect(await erc20Contract.allowance(addr1, addr2)).to.equal(50);
      });

      it("should fail if allowance is insufficient", async () => {
        await expect(
          erc20Contract.connect(addr2).transferFrom(addr1, addr3, 300)
        ).to.be.revertedWithCustomError(erc20Contract, "insufficientAllowance");
      });

      it("should fail if owner balance is insufficient", async () => {
        await erc20Contract.connect(addr1).approve(addr2, 1000);
        await expect(
          erc20Contract.connect(addr2).transferFrom(addr1, addr3, 800)
        ).to.be.revertedWithCustomError(erc20Contract, "insufficientBalance");
      });

      it("should revert if owner is address(0)", async () => {
        await expect(
          erc20Contract.connect(addr2).transferFrom(ZeroAddress, addr3, 50)
        )
          .to.be.revertedWithCustomError(erc20Contract, "invalidAccount")
          .withArgs(ZeroAddress);
      });

      it("should revert if receipient is zero address", async () => {
        await expect(
          erc20Contract.connect(addr2).transferFrom(addr1, ZeroAddress, 50)
        )
          .to.be.revertedWithCustomError(
            erc20Contract,
            "invalidreceipientAccount"
          )
          .withArgs(ZeroAddress);
      });
    });
  });

  describe("Events", () => {
    beforeEach(async () => {
      await erc20Contract.connect(owner).mint(addr1, 500);
    });

    it("should emit Transfer event on transfer", async () => {
      await expect(erc20Contract.connect(addr1).transfer(addr2, 200))
        .to.emit(erc20Contract, "Transfer")
        .withArgs(addr1.address, addr2.address, 200);
    });

    it("should emit Transfer event on mint", async () => {
      await expect(erc20Contract.connect(owner).mint(addr2, 300))
        .to.emit(erc20Contract, "Transfer")
        .withArgs(erc20Contract.target, addr2.address, 300);
    });

    it("should emit Approve event on approve", async () => {
      await expect(erc20Contract.connect(addr1).approve(addr2, 250))
        .to.emit(erc20Contract, "Approve")
        .withArgs(addr1.address, addr2.address, 250);
    });

    it("should emit TransferFrom event on transferFrom", async () => {
      await erc20Contract.connect(addr1).approve(addr2, 200);

      await expect(erc20Contract.connect(addr2).transferFrom(addr1, addr3, 150))
        .to.emit(erc20Contract, "TransferFrom")
        .withArgs(addr1.address, addr3.address, 150);
    });
  });
});
