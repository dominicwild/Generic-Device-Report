import React, { Component } from "react";
import "../css/Report.css";
import Datatable from "./Datatable";
import ExpandPanel from "./ExpandPanel";
import Overview from "./Overview";
import ReportData from "./ReportData";

const config = window.config;

class Report extends Component {
  render() {

    return (
      <div className="report">
        <div className="header">System Report</div>
        <div className="body">
          <Overview data={config.Overview} />
          <ExpandPanel />
          <ReportData />
        </div>

        {/* <div className="footer"></div> */}
      </div>
    );
  }
}

export default Report;
