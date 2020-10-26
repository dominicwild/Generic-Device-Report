import React, { Component } from 'react';

class GlobalSearch extends Component {

    constructor(props){
        super(props)
        this.state = {
            search: ""
        }
    }

    onChange = (e) => {
        const newSearch = e.target.value;
        let allSearch = document.querySelectorAll("div.dataTables_filter label input[type='search']")
        this.setState({
            search: newSearch
        })
    }

    render() {
        const {search} = this.state
        return (
            <div className="global-search">
                <input type="text" name="global-search" id="globalSearch" value={search} onChange={this.onChange}/>
            </div>
        );
    }
}

export default GlobalSearch;