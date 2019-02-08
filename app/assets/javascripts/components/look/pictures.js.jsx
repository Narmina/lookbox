// hack to escape turbolinks Warning: unmountComponentAtNode(): The node you're attempting to unmount was rendered by another copy of React
// fixed from version 2.0 'react-rails'
ReactRailsUJS.handleEvent('turbolinks:before-cache', function() {window.ReactRailsUJS.unmountComponents()});

LookPictures = React.createClass({
  getInitialState: function () {
    let look_pictures = JSON.parse(this.props.look_pictures)
    return {
      look_pictures: look_pictures,
      max_position_order: look_pictures.length + 1,
      pictures_for_remove_count: 0,
      modal_picture: false
    }
  },
  findPictureById: function(look_pictures, picture_id){
    return look_pictures.find((lp) => { if (lp.picture_id == picture_id) return lp })
  },
  changePositionParams: function(picture_id, position_params){
    let look_pictures = this.state.look_pictures.slice()
    let lp = this.findPictureById(look_pictures, picture_id)
    look_pictures[look_pictures.indexOf(lp)]['position_params'] = position_params
    this.setState({look_pictures: look_pictures})
  },
  changeMaxPositionOrder: function(){
    this.setState({max_position_order: this.state.max_position_order + 1})
    return this.state.max_position_order
  },
  changePicturesForRemoveCount: function(counter){
    this.setState({pictures_for_remove_count: this.state.pictures_for_remove_count + counter})
    return this.state.pictures_for_remove_count
  },
  clearTrash: function(e){
    this.setState({pictures_for_remove_count: 0})
  },
  duplicatePicture: function(picture_id){
    new_look_picture = this.findPictureById(this.state.look_pictures, picture_id)
    new_look_picture.id = ''
    new_look_picture.position_params = {left: new_look_picture.position_params.left - 30, top: new_look_picture.position_params.top - 30, order: new_look_picture.position_params.order  }
    this.setState({look_pictures: this.state.look_pictures.concat(new_look_picture)})
  },
  showModalView(picture){
    this.setState({modal_picture: picture})
  },
  componentWillMount(){
    window.Look = {
      addPictures: (data='') => {
        added_pictures = JSON.parse(data)
        //const merge = (a, b, key = 'picture_id') => a.filter(elem => !b.find(subElem => subElem[key] === elem[key])).concat(b)
        //new_pictures = merge(this.state.look_pictures, added_pictures)
        this.setState({look_pictures: this.state.look_pictures.concat(added_pictures)})
      }
    }
  },
  render: function() {
    return(
      <div>
        {this.state.pictures_for_remove_count > 0 &&
          <div className="look-pictures-action"><span className="glyphicon glyphicon-remove-circle" title="Clear trash" onClick={ this.clearTrash }></span></div>
        }
        { this.state.look_pictures.map(function(lp, index){
          return <LookPictureItem key={`lp_${index}_${lp.id}_`} lp_id={lp.id} index = {index}
                                  picture = {lp.picture} position_params = {lp.position_params}
                                  pictures_for_remove_count = {this.state.pictures_for_remove_count}
                                  duplicatePicture = {this.duplicatePicture}
                                  changePositionParams = {this.changePositionParams}
                                  changePicturesForRemoveCount = {this.changePicturesForRemoveCount}
                                  showModalView={this.showModalView}
                                  changeMaxPositionOrder = {this.changeMaxPositionOrder}/>}.bind(this)) }
        <div className="modal fade" id="picture-modal-show" tabIndex="-1" role="dialog" aria-labelledby= "modal-label">
          {this.state.modal_picture &&
            <PictureModalShow picture={this.state.modal_picture}/>
          }
        </div>
      </div>
    )
  }
})

LookPictureItem =  React.createClass({
  getDefaultProps: function () {
    return { lp_id: ''}
  },
  getInitialState: function () {
    return {
      show_item: true,
      position_params:  Object.assign({}, {left: '0', top: '0', order: '1', height: 300, width: 'auto'}, this.props.position_params),
      hidden_fields: { 'id': this.props.lp_id, 'picture_id': this.props.picture.id, '_destroy': false }
    }
  },
  componentWillMount(){
    if (this.props.lp_id =='') this.increaseZindex()
  },
  setHiddenFields: function(){
    return(
        <div id={`look-picture-${this.props.picture.id}-position-${this.props.index}`}>
          { Object.keys(this.state.hidden_fields).concat(Object.keys(this.state.position_params)).map((field_name) => {
            //let name_prefix = (field_name in this.state.position_params) ? 'position_' : ''
            return <input type="hidden"
                          key={`lp_hidden_${ this.props.index}_${field_name}`}
                          value={field_name == '_destroy' ? !this.state.show_item : (this.state.position_params[field_name] || this.state.hidden_fields[field_name])}
                          name={`look[look_pictures_attributes][${this.props.index}][${field_name}]`}
                          id={`look_look_pictures_attributes_${this.props.index}_${field_name}`} /> }) }
        </div>
    )
  },
  changePositionParams: function(position){
    this.setState({ position_params: {...this.state.position_params, ...position } })
    this.props.changePositionParams(this.props.picture.id, position)
  },
  increaseZindex: function(e){
    new_zindex = this.props.changeMaxPositionOrder()
    this.setState({ position_params: {...this.state.position_params, ['order']:  new_zindex} })
    $(ReactDOM.findDOMNode(this)).find('.ui-wrapper').css('z-index', new_zindex) // hack for resizable
  },
  removePicture: function(e){
    e.stopPropagation()
    this.setState({show_item: false})
    this.props.changePicturesForRemoveCount(1)
    look_pictures_ids = $.cookie('look_pictures_ids').split(',')
    index = $.inArray(this.props.picture.id.toString(), look_pictures_ids)
    if (index >= 0) {
      look_pictures_ids.splice(index, 1)
      $.cookie('look_pictures_ids', look_pictures_ids.join(','), {path: '/'})
    }
  },
  duplicatePicture: function(e){
    this.props.duplicatePicture(this.props.picture.id)
  },
  goToLink(){
    window.open(this.props.picture.link, '_blank')
  },
  undoPictureRemove: function(e){
    this.setState({show_item: true})
    this.props.changePicturesForRemoveCount(-1)
  },
  showModalView(e){
    this.props.showModalView(this.props.picture)
  },
  componentDidMount(){
    resizeable_options = {
      handles: 's, e',
      minHeight: 30,
      minWidth: 30,
      maxWidth: 500,
      maxHeight: 500,
      aspectRatio: true, // resize image proportionally
      stop: (event, ui) => {
        this.changePositionParams({width: ui.size.width.toFixed(), height: ui.size.height.toFixed()})
      }
    }
    $(ReactDOM.findDOMNode(this)).find('.resizable').resizable(resizeable_options)
  },
  handleSize(image){
    if (this.state.position_params.width == 'auto' && image != null) {
      image.onload = function(e) {
        [ width, height ] = [ e.currentTarget.naturalWidth, e.currentTarget.naturalHeight ]
        if ( height > this.state.position_params.height) {
          width = Math.round(parseInt(this.state.position_params.height) * width / height)
          height = this.state.position_params.height
        }
        this.setState({position_params: {...this.state.position_params, ['width']: width, ['height']: height}})
        wrapper = $(ReactDOM.findDOMNode(this)).find('.ui-wrapper')
        wrapper.css('width', width);  wrapper.css('height', height) // hack for resizable
      }.bind(this);
    }
  },
  render: function(){
    return(
        <div className = 'look-picture-block' style={{zIndex: this.state.position_params['order'] }}>
          { this.state.show_item &&
          <Draggable position={this.props.position_params} canvas_id = { ConstantsList.LookCanvasID }
                     changePositionParams={ this.changePositionParams } increaseZindex={ this.increaseZindex }>
              <img className="resizable" src={this.props.picture.image.large.url} title=''
                   style={{ width: this.state.position_params.width + 'px', height: this.state.position_params.height + 'px',
                   zIndex: this.state.position_params['order'] }}
                   onClick={this.increaseZindex}
                   ref = {image => { this.handleSize(image) } }
              />
            <div className="picture-action">
               { this.props.picture.link &&
                 <span className="glyphicon glyphicon-link" title="Go to link"
                     style={{zIndex: this.state.position_params['order'] }} onClick={this.goToLink}></span>
               }
               <span className="glyphicon glyphicon-duplicate" title="Make a copy" style={{zIndex: this.state.position_params['order'] }} onClick={this.duplicatePicture}></span>
               <span className="glyphicon glyphicon-trash" title="Move to trash" style={{zIndex: this.state.position_params['order'] }} onClick={this.removePicture}></span>
               <span className="glyphicon glyphicon-zoom-in" title="Show" data-toggle="modal" data-target={`#picture-modal-show`} style={{zIndex: this.state.position_params['order'] }} onClick={this.showModalView}></span>
             </div>
          </Draggable>
          }
          {!this.state.show_item && this.props.pictures_for_remove_count > 0 &&
            <div className="look-pictures-action undo-picture-removing">
                 <span className="glyphicon glyphicon-trash" title="Restore picture"
                       style={{zIndex: this.state.position_params['order'] }} onClick={this.undoPictureRemove}></span>
                 <span title="picture(s) to restore" style={{backgroundColor: 'white'}}><b>{this.props.pictures_for_remove_count}</b></span>
            </div>
          }
          { this.setHiddenFields() }
        </div>
    )
  }
})

