/** @jsx React.DOM */

(function () {
  window.QuestionForm = React.createClass({
    render: function() {
      return (
        <div class="question">
          Current Question: {this.state.questionText}
          <form onSubmit={this.props.handleSubmit}>
            <input value={this.state.answer} />
            <button>Submit</button>
          </form>
        </div>
      );
    }
  });

  window.Chart = React.createClass({
    render: function() {
      return (
        <div class="chart">
          A cool chart!
        </div>
      );
    }
  });

  window.Progress = React.createClass({
    render: function() {
      return (
        <div class="progress">
          Proficiency: {this.state.proficiency}<br></br>
          Level: {this.state.questionLevel}<br></br>
        </div>
      );
    }
  });

  window.Streaks = React.createClass({
    render: function() {
      return (
        <div class="streaks">
          Current Streak: {this.state.currentStreak}<br></br>
          Longest Streak: {this.state.longestStreak}<br></br>
        </div>
      );
    }
  });
  React.renderComponent(
  <QuestionForm />,
  document.getElementById('question')
);
});
React.renderComponent(
  <Chart />,
  document.getElementById('chart')
);
});
React.renderComponent(
  <Progress />,
  document.getElementById('progress')
);
});
React.renderComponent(
  <Streaks />,
  document.getElementById('streaks')
);
});
})();
