import React, { Component } from "react";
import Datatable from "./Datatable";
import "../css/ReportData.css"

class ReportData extends Component {
  render() {
    const tables = window.config.Tables;

    return (
      <div className="report-data">
        {tables.map((table) => {
          const id = table.title.replaceAll(" ", "-").replaceAll("(", "").replaceAll(")", "")
          if(table.data.map != null){
            return <Datatable config={table.options} data={table.data} columns={table.columns} title={table.title} id={id} key={`${table.title}table}}`}/>;
          }
          return "";
        })}
      </div>
    );
  }
}

export default ReportData;
