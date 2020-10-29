import React, { Component } from "react";
import OverviewPanel from "./OverviewPanel";
import "../css/Overview.css";

class Overview extends Component {
  render() {
    const { data } = this.props;

    return (
      <div className="overview">
        {data.map((panel) => {
          if (panel.data && Object.keys(panel.data).length != 0) {
            return <OverviewPanel panel={panel} key={panel.title} />;
          }
        })}
        {/* <OverviewPanel panel={data[0]} /> */}
      </div>
    );
  }
}

export default Overview;
