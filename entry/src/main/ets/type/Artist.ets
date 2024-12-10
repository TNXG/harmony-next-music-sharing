import { Track } from "./Playlist";
import { Artist } from "./Song";

/**
 * 歌手响应
 */
@Observed
export class ArtistResponse {
  artist: Artist = new Artist();
  hotSongs: Track[] = [];

  constructor(response?: ArtistResponse) {
    if (response !== undefined) {
      this.artist = new Artist(response.artist);
      this.hotSongs = response.hotSongs.map(track => new Track(track));
    }
  }
}