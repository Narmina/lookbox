//cl = cloudinary.Cloudinary.new({cloud_name: "lookbox"})
//cl.responsive()

Pictures = React.createClass({getInitialState(){
    return{
      pictures: JSON.parse(this.props.pictures),
      modal_picture: false,
      zoom_loupe: false
    }
  },
  showModalView(picture){
    this.setState({modal_picture: picture})
  },
  changePictureModal(index){
    picture = this.state.pictures[index]
    this.setState({modal_picture: this.preloadImage(picture)})
  },
  switchZoomLoupe(){
    this.setState({zoom_loupe: !this.state.zoom_loupe})
  },
  preloadImage(picture){
    return{...picture,
       ['image']: {large: {url: picture.image.large.url || `images/${ConstantsList.Images.noImageLarge}`},
          thumb: {url: picture.image.thumb.url || `images/${ConstantsList.Images.noImageSmall}`}},
        ['has_image']: Boolean(picture.image.url)
      }
  },
  //setImageTimeStamp(url, image_timestamp){
  //  if (image_timestamp && url) url += '?v=' + image_timestamp
  //  return url
  //},
  updatePicturesList(picture, index){
    if ($.isEmptyObject(picture) || index < 0) return
    new_pictures = this.state.pictures
    possible_categories = picture.possible_categories.length > 0 ? picture.possible_categories : [-1]
    selected_categories = Array.from(document.getElementById("q_category_search").options).filter(option => option.selected).map(option => option.value)
    has_intersection = possible_categories.some(cat => selected_categories.indexOf(String(cat)) >= 0)
    if (selected_categories.length > 0 && !has_intersection) new_pictures.splice(index, 1)
    else if (index > this.state.pictures.length) new_pictures.unshift(picture)
    else new_pictures[index] = picture
    this.setState({pictures: new_pictures})
  },
  componentWillMount(){
    window.Picture = {
      addPicture:function(data = '{}'){
        picture = JSON.parse(data)
        this.updatePicturesList(picture, this.state.pictures.length + 1)
      }.bind(this),
      updatePicture: function (data = '{}') {
        picture = JSON.parse(data)
        index = this.state.pictures.findIndex((p) => p.id == picture.id)
        this.updatePicturesList(picture, index)
      }.bind(this)
    }
  },
  render(){
    that = this
    return(
        <div>
          {
            this.state.pictures.map(function (pict, index) {
              if (index > 0) pict.previous_index = (index - 1).toString()
              if (index < that.state.pictures.length - 1) pict.next_index = index + 1
              return <PictureItem key={index} index={index} picture={that.preloadImage(pict)} showModalView={that.showModalView}/>
            })
          }
          <div className="modal fade" id="picture-modal-show" tabIndex="-1" role="dialog" aria-labelledby= "modal-label">
            {this.state.modal_picture &&
              <PictureModalShow picture={this.state.modal_picture}
                                zoom_loupe={this.state.zoom_loupe}
                                changePictureModal={this.changePictureModal}
                                switchZoomLoupe={this.switchZoomLoupe}/>
            }
          </div>
        </div>
    )
  }
})


PictureItem = React.createClass({
  getInitialState(){
    return{
            picture: this.props.picture
          }
  },
  showModalView(e){
    this.props.showModalView(this.props.picture)
  },
  render(){
    //$.cloudinary.image(this.props.picture.image.thumb.url, {angle: -30, opacity: 70})
    //picture_transformed = cl.imageTag(this.props.picture.file_name, {crop: 'scale', width: 150, height: 150, angle: 0}).toHtml()
    //<span dangerouslySetInnerHTML={{__html:  picture_transformed}} />
    //or for simple string cl.url(this.props.picture.file_name, {crop: 'scale', width: 150, height: 150, angle: 0})
    return(
        <div className='picture-block'>
          <div className='image-block'>
            <a href="#" data-toggle="modal" data-target={`#picture-modal-show`} onClick={this.showModalView}>
              <img className="image-space" src={this.props.picture.image.thumb.url} alt="No image"/>
            </a>
          </div>
          <div className="picture-action">
            { this.props.picture.link &&
              <a href={this.props.picture.link} target="_blank" title={this.props.picture.link}>
                <span className="glyphicon glyphicon-link"></span>
              </a>
            }
            <a href="#" title="Show" data-toggle="modal" data-target={`#picture-modal-show`} onClick={this.showModalView}>
              <span className="glyphicon glyphicon-zoom-in"></span>
            </a>
            <a href={`/pictures/${this.props.picture.id}/edit`} title="Edit" data-remote="true" data-toggle="modal" data-target={`#picture-modal-form`}>
              <span className="glyphicon glyphicon-edit"></span>
            </a>
            <a data-confirm="Are you sure?" title="Delete" rel="nofollow" data-method="delete" href={`/pictures/${this.props.picture.id}`}>
              <span className="glyphicon glyphicon-trash"></span>
            </a>
          </div>
          <div className="picture-title">{this.props.picture.title}</div>
        </div>
    )
  }
})

PictureItem.propTypes = {
  picture: React.PropTypes.shape({
            title: React.PropTypes.string.isRequired,
            link: React.PropTypes.string
  })
};

