var Draggable = React.createClass({
  getDefaultProps: function () {
    return {
      // allow the initial position to be passed in as a prop
      position: {left: 0, top: 0},
      canvas_id: null
    }
  },
  getInitialState: function () {
    return {
      position: this.props.position,
      dragging: false,
      canvas_offset: this.getCanvasOffset(this.props.canvas_id),
      rel: null // position relative to the cursor
    }
  },
  getCanvasOffset: function(canvas_id){
    let canvas_offset = {left: 0, top: 0}
    let canvas_elem = document.getElementById(canvas_id)
    if (canvas_elem) {
      let canvas_offset_elem = canvas_elem.getBoundingClientRect()
      canvas_offset = {left: canvas_offset_elem.left, top: canvas_offset_elem.top}
    }
    return canvas_offset
  },
  componentDidUpdate: function (props, state) {
    [on_move, on_end] = ConstantsList.isMobileDevice ? ['touchmove', 'touchend' ] : ['mousemove', 'mouseup']
    if (this.state.dragging && !state.dragging) {
      document.addEventListener(on_move, this.onMouseMove)
      document.addEventListener(on_end, this.onMouseUp)
    } else if (!this.state.dragging && state.dragging) {
      document.removeEventListener(on_move, this.onMouseMove)
      document.removeEventListener(on_end, this.onMouseUp)
    }
  },
  componentDidMount: function() {
    document.addEventListener('scroll', this.handleScroll, false);
  },
  componentWillUnmount: function() {
    document.removeEventListener('scroll', this.handleScroll, false);
  },
  handleScroll: function(e){
      this.setState({canvas_offset: this.getCanvasOffset(this.props.canvas_id) })
  },
  onMouseDown: function (e) {
    // only left mouse button
    if (e.button !== 0) return
    let pos = ReactDOM.findDOMNode(this).getBoundingClientRect()
    let [position_page_x, position_page_y] = this.getPagePositions(e)
    this.setState({
      dragging: true,
      rel: {
        x: position_page_x - pos.left + this.state.canvas_offset.left,
        y: position_page_y - pos.top + this.state.canvas_offset.top
      }
    })
    this.props.increaseZindex()
    e.stopPropagation()
    e.preventDefault()
  },
  onMouseUp: function (e) {
    this.setState({dragging: false})
    this.props.changePositionParams(this.state.position)
    e.stopPropagation()
    e.preventDefault()
  },
  onMouseMove: function (e) {
    if (!this.state.dragging) return
    //if (window.getComputedStyle(ReactDOM.findDOMNode(this)).cursor != 'move') return
    if (e.target.width == undefined) return
    let [position_page_x, position_page_y] = this.getPagePositions(e)
    this.setState({
      position: {
        left: position_page_x - this.state.rel.x,
        top: position_page_y - this.state.rel.y
      }
    })
    if (!ConstantsList.isMobileDevice) e.preventDefault()
  },
  getPagePositions(e){
    return ConstantsList.isMobileDevice ? [e.changedTouches[0].pageX, e.changedTouches[0].pageY] : [e.pageX, e.pageY]
  },
  render: function () {
    return(
        <div style={{ position: 'absolute', left: this.state.position.left + 'px', top: this.state.position.top + 'px'}}
             onMouseDown = {this.onMouseDown} onTouchStart = {this.onMouseDown} >{this.props.children}</div>
    )
  }
})

