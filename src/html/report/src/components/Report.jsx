import React, { Component } from "react";
import "../css/Report.css";
import Datatable from "./Datatable";
import ButtonPanel from "./ButtonPanel";
import Overview from "./Overview";
import ReportData from "./ReportData";
import GlobalSearch from "./GlobalSearch";


const config = window.config;

class Report extends Component {

  render() {
    return (
      <div className="report">
        <div className="header">System Report</div>
        <div className="body">
          <Overview data={config.Overview} />
          <ButtonPanel />
          {/* <GlobalSearch /> */}
          <ReportData />
        </div>

        {/* <div className="footer"></div> */}
      </div>
    );
  }
}

export default Report;
