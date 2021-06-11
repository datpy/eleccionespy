import pathlib
from typing import Tuple, TypedDict
from numpy import float128

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

from adjustText import adjust_text
from ..stats import Stats


class StatCor(TypedDict):
    show: bool
    x_pos: float
    y_post: float


class Grapher:
    """
    Grapher defines methods to create scatter plots for different independent
    variables in the development indicators dataframe.
    """

    def __init__(self, devIndicators: pd.DataFrame, stats: Stats) -> None:
        self.devIndicators = devIndicators
        self.income = devIndicators.query("indicador == 'ECON_IMAP'")
        self.stats = stats

        style = str(pathlib.Path(__file__).parent) + "/.mplstyle"
        plt.style.use(style)

    def make_vs_indicator_graph(
        self,
        indicator: str,
        df: pd.DataFrame,
        y_column: str,
        title: str,
        xlab: str,
        ylab: str,
        xticksuffix: str = "",
        yticksuffix: str = "",
        indicator_factor: float = 1.0,
        xlim: Tuple[int, int] = None,
        stat_cor: StatCor = {'show': False}
    ):
        """
        Takes a data frame and the column to be used as the dependent variable
        and creates a plot with the provided development indicator as the
        independent variable.

        Parameters
        ----------
        df : Dataframe
            The dataframe that contains the dependent variable and the column
            by which to merge the dependent and independent variables.
        indicator : String
            Development indicator variable to use as independent variable.
        y_column: String
            The dependent variable's column name in dataframe.
        title: String
            The plot's title.
        xlab: String
            The x axis label.
        ylab: String
            The y axis label.
        yticksuffix:
            Suffix to add to the dependent variable's ticks such as "%".
        indicator_factor: Float
            Scale indicator value by this factor.
        """

        # Queries for the requested indicator and creates a pandas dataframe
        # with dev_indicator as a column that contains the indicator's values.
        #
        # The values are then divided by the provided factor.
        dev_ind = self.devIndicators.query(f"indicador == '{indicator}'")
        dev_ind = dev_ind[["dep", "valor"]]
        dev_ind = dev_ind.rename(columns={"valor": indicator})
        dev_ind[indicator] = dev_ind[indicator] * indicator_factor

        mergedDf = df.merge(dev_ind, on="dep")

        # Creates regression plot.
        ax = sns.regplot(
            x=mergedDf[indicator],
            y=mergedDf[y_column],
            ci=None,
            scatter_kws={"fc": "none", "edgecolor": "black"},
            line_kws={"color": "red"}
        )
        ax.set(xlabel=xlab, ylabel=ylab, title=title)

        if xlim:
            ax.set_xlim(xlim)

        # Adds suffix to x ticks.
        ticks = plt.yticks()[0]
        xlabels = [f"{x:.0f}{xticksuffix}" for x in ticks]
        plt.yticks(ticks=ticks, labels=xlabels)

        # Adds suffix to y ticks.
        ticks = plt.yticks()[0]
        ylabels = [f"{y:.0f}{yticksuffix}" for y in ticks]
        plt.yticks(ticks=ticks, labels=ylabels)

        # Add labels for each point.
        self.label_points(
            mergedDf[indicator],
            mergedDf[y_column],
            mergedDf["depdes"]
        )

        if stat_cor['show']:
            annotation = self.stats.r_and_p_value(
                mergedDf[indicator],
                mergedDf[y_column]
            )
            ax.text(stat_cor["x_pos"], stat_cor["y_pos"], annotation,
                    fontsize=16, fontstyle="italic", c="darkblue")

        return ax.plot()

    def make_vs_income_graph(
        self, df: pd.DataFrame, y_column: str, title: str, xlab: str,
        ylab: str
    ):

        """
        Takes a data frame and the column to be used as the dependent variable
        and creates a plot with income as the independent variable.

        See `Grapher.make_vs_indicator_graph`
        """

        return self.make_vs_indicator_graph(
            "ECON_IMAP", df, y_column, title, xlab, ylab, '%',
            indicator_factor=1/1000000,
            xlim=(1.3, 4.5),
            stat_cor={'show': True, 'x_pos': 2.5, 'y_pos': 30}
        )

    def make_vs_poverty_graph(
        self, df: pd.DataFrame, y_column: str, title: str, xlab: str,
        ylab: str,
    ):
        """
        Takes a data frame and the column to be used as the dependent variable
        and creates a plot with poverty as the independent variable.

        See `Grapher.make_vs_indicator_graph`
        """

        return self.make_vs_indicator_graph(
            "PBRZ_PTOTL", df, y_column, title, xlab, ylab,
            xticksuffix='%', yticksuffix='%',
            xlim=(10, 50),
            stat_cor={'show': True, 'x_pos': 26, 'y_pos': 35}
        )

    def label_points(self, x: pd.Series, y: pd.Series, labels: pd.Series):
        """
        For each given datapoint, add a label to it.
        """

        texts = [plt.text(x[i], y[i], labels[i]) for i in range(labels.size)]

        adjust_text(
            texts,
            force_points=(0.5, 0.5),
            expand_points=(1.2, 1.2)
        )
