import React, { Component } from "react";
import SVG from "react-inlinesvg";
import $ from "jquery";
import "datatables.net-dt/css/jquery.dataTables.css";
import "../css/Datatable.css";
import "moment";
import "datetime-moment";
import Carat from "../SVG/Carat";

$.DataTable = require("datatables.net");

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
      dom: '<"top"if>rt<"bottom"lp><"clear">',
    };

    if (config) {
      options = { ...options, ...config };
    }

    $(`#${id}`).DataTable({
      ...options,
    });

    if (config?.dateFormat) {
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
    console.log(data);
    // console.log(columns);

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
                          val = col.function(val, row);
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
