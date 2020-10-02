import React, { Component } from "react";
import "../css/Button.css";
import "../css/ExpandPanel.css";

class ExpandPanel extends Component {
  expandAll = () => {
    document.querySelectorAll(".hidden").forEach((element) => {
      element.click();
    });
  };

  collapseAll = () => {
    document.querySelectorAll(".collapsable").forEach((element) => {
      if (!element.classList.contains("hidden")) {
        element.click();
      }
    });
  };

  render() {
    return (
      <div className="expand-panel">
        <a className="button expand-btn" onClick={this.expandAll}>
          Expand All
        </a>
        <a className="button collapse-btn" onClick={this.collapseAll}>
          Collapse All
        </a>
      </div>
    );
  }
}

export default ExpandPanel;
