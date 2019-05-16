from enochecker import BaseChecker, BrokenServiceException, run

session = requests.Session()


class ShittrChecker(BaseChecker):

    def putflag(self):
        pass

    def getflag(self):
        pass

    def putnoise(self):
        pass

    def getnoise(self):
        pass

    def havoc(self):
        pass


app = ShittrChecker.service
if __name__ == "__main__":
    run(ShittrChecker)
