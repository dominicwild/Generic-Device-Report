import React, { Component } from "react";
import "../css/OverviewPanel.css";

class OverviewPanel extends Component {
  render() {
    const { panel } = this.props;
    return (
      <div className="overview-panel">
        <div className="title">
          <h1>{panel.title}</h1>
        </div>
        <div className="content">
          <table>
            <tbody>
              {panel.data.map(({ Name, Value, modify }) => {
                // Value = panel.data[Value]
                if (modify) {
                  try {
                    Value = modify(Value);
                  } catch (err) {
                    console.error(err);
                    Value = "Unknown";
                  }
                }

                if("" + Value === "true"){
                  Value = "true ✔️"
                }
                if("" + Value === "false"){
                  Value = "false ❌"
                }
                
                if (Value === null) {
                  Value = "Unknown";
                }
                return (
                  <tr key={`${Name}${Value}`} className="row">
                    <td className="key">{Name}</td>
                    <td className="value">{"" + Value}</td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>
    );
  }
}

export default OverviewPanel;
