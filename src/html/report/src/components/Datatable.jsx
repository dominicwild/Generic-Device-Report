import React, { Component } from "react";
import SVG from "react-inlinesvg";
import $ from "jquery";
import "datatables.net-dt/css/jquery.dataTables.css";
import "../css/Datatable.css";
import "moment/min/moment.min.js";
import "datetime-moment/datetime-moment.js";
import Carat from "../SVG/Carat";
import jsZip from "jszip";
import "datatables.net-buttons/js/buttons.colVis.min";
import "datatables.net-buttons/js/dataTables.buttons.min";
import "datatables.net-buttons/js/buttons.flash.min";
import "datatables.net-buttons/js/buttons.html5.min";

import pdfMake from "pdfmake/build/pdfmake";
import pdfFonts from "pdfmake/build/vfs_fonts";
pdfMake.vfs = pdfFonts.pdfMake.vfs;

window.JSZip = jsZip;

$.DataTable = require("datatables.net");

require("datatables.net-keytable-dt");
require("datatables.net-searchpanes-dt");

class Datatable extends Component {
  constructor(props) {
    super();
    this.state = {};
  }

  componentDidMount = () => {
    const { data, config, id } = this.props;
    const paging = (data.length > 15) | config?.paging;

    let options = {
      paging,
      dom: '<"top"iBf>rt<"bottom"lp><"clear">',
    };

    if (config) {
      options = { ...options, ...config };
    }
    const title = `Device Report - ${id}`;

    $(`#${id}`).DataTable({
      ...options,
      buttons: [
        "copyHtml5",
        {
          extend: "pdfHtml5",
          orientation: "landscape",
          pageSize: "LEGAL",
          title,
        },
        {
          extend: "excelHtml5",
          title,
        },
        {
          extend: "csvHtml5",
          title,
        },
      ],
    });

    if (config?.dateFormat) {
      $.fn.dataTable.moment(config.dateFormat);
      // $(`#${this.props.id}`).DataTable.moment(config.dateFormat);
    }

    const element = document.querySelector(`#${id}`).closest(".transition-container");
    // element.style.maxHeight = element.scrollHeight + "px";
    element.addEventListener("onclick", this.setHeight);
    element.querySelectorAll(".paginate_button").forEach((item) => {
      item.addEventListener("onclick", this.setHeight);
    });

    const select = document.querySelector(`#${id}_wrapper select[name="${id}_length"]`);
    if (select) {
      select.addEventListener("onchange", (e) => {
        // element.style.maxHeight = element.scrollHeight + "px";
      });
    }
  };

  makeFooter = () => {
    const { data, columns, id } = this.props;
    if (data.length > 15) {
      return (
        <tfoot>
          <tr>
            {columns.map((col) => {
              return <th key={`${id}${col.Name}bottom}}`}>{col.Name}</th>;
            })}
          </tr>
        </tfoot>
      );
    }
  };

  onClick = (e) => {
    const dataTableContainer = e.target.closest(".datatable-container");
    const target = dataTableContainer.querySelector(".transition-container");
    if (!dataTableContainer.classList.contains("hidden")) {
      dataTableContainer.classList.add("hidden");
      e.target.classList.add("hidden");
    } else {
      dataTableContainer.classList.remove("hidden");
      e.target.classList.remove("hidden");
    }
  };

  setHeight = (e) => {
    const { id } = this.props;
    const element = document.querySelector(`#${id}`).closest(".transition-container");
    // element.style.maxHeight = element.scrollHeight + "px";
  };

  render() {
    const { data, columns, id, title, config } = this.props;

    return (
      <div className="datatable-container">
        <h1 onClick={this.onClick} className="collapsable">
          <span className="title">{title}</span>
          <div className="expand-icon">
            <Carat />
          </div>
        </h1>
        <div className={`transition-container`}>
          <div className={`datatable-table`}>
            <table id={id} className="display">
              <thead>
                <tr>
                  {columns.map((col) => {
                    return (
                      <th key={`${id}${col.Name}top}}${Math.random()}`} className={col.Name.replace(" ", "-")} style={col.style}>
                        {col.Name}
                      </th>
                    );
                  })}
                </tr>
              </thead>
              <tbody>
                {data.map((row, index) => {
                  return (
                    <tr key={`${id}${index}row}}${Math.random()}`}>
                      {columns.map((col) => {
                        let val = row[col.Value];
                        if (col.function) {
                          try {
                            val = col.function(val, row);
                          } catch (err) {
                            console.log("Exception thrown that caused unknown value error.");
                            console.error(err);
                            val = "Unknown";
                          }
                        }
                        if (val == null) {
                          val = "Unknown";
                        }
                        return <td key={`${id}${col.Name}${val}val}}${Math.random()}`}>{val}</td>;
                      })}
                    </tr>
                  );
                })}
              </tbody>
              {this.makeFooter()}
            </table>
          </div>
        </div>
      </div>
    );
  }
}

export default Datatable;
