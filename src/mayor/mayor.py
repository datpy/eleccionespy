import pandas as pd
from .departmentwise import Departmentwise


class Mayor(Departmentwise):
    def __init__(self, electionResults):
        self.electionResults = electionResults
